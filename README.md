# README

This is the README file for the `doc-converter` project.  The
`doc-converter` project implements an HTTP service, architected to run
in the Amazon AWS envrironment, for among other things, converting
.xls[x] and .doc[x] documents to PDF.  This project will produce two
RPMs:

- `doc-converter-1.0.0-0.rpm`
- `doc-converter-client-1.0.0-0.rpm`

...or some other versioned RPMs. Just to be clear, this project's
targets are RPMs that you can then use to create a document conversion
server and client.  In other words, you build these RPMs then follow
some additional instructions in order to create the server.

If you don't want to create your own customized RPMs you can try
to install the RPMs (no guarantees that they will actually work for you
however) from the quasi-official `doc-converter` yum repository:

```
[doc-converter]
baseurl=https://doc-converter.s3-website-us-east-1.amazonaws.com
name=doc-converter
gpgcheck=0
enabled=1
```

# Amazon AWS Architecture

The `doc-converter` service employs your S3 bucket as a document
repository.  Both the `doc-converter` client and server use the S3
bucket for storing documents.  In ASCII art, the architecture looks
something like this:

```
          +------<<< S3 bucket policy >>>-------+
          |                                     |
          | s3://mybucket                       |
          |                                     |
          |                   10.0.1.81         |
     _____o_____              +-------+         |
     \         / .xls[x], ... |       |    -----o----
      \  S3   /  -----------> |  EC2  o---{ IAM Role }
       \     /  <------------ |       |    ----------
        \___/  .pdf, .png     +-+-----+
          ^                  /  +-- LibreOffice
          |                 /   +-- ImageMagick
          |.txt      ///////    +-- Apache
          |.xls[x]  /       
          |.doc[x] / GET/POST
          |       / 
     +--------+  /   $ curl http://10.0.1.81/converter/mybucket/FE76C51A-872D-11E5-89DF-3E269020DED9
     |        | /         
     | Client |/
     |        | 
     +--------+  $ doc2pdf-client -b mybucket -h 10.0.1.81 test.xlsx

```

Your clients push documents to your S3 bucket and then request a
conversion service via an HTTP endpoint.  The server reads the bucket
and converts the documents.  The client can then retrieve the PDF
and/or .png files.

## Architectural Considerations and Alternatives

S3 buckets can also be configured to generate various events when
objects are modified in the S3 bucket.  The S3 service can generate:

1. an SQS notification
2. an SNS notification
3. a Lambda event

In the the first two scenarios, we would need some subscriber to those
events, either a queue handler of some kind that reads the SQS queue
waiting for these events or an endpoint that handles SNS
notifications.  In either case, we would need to provision an EC2
instance of some sort to run our code.

*Scenario 3* is clearly more appealing.  That is, create a Lambda
function that responds to the S3 event and then perform some magic on
the documents.  While this appears a bit more appealing
architecturally, it introduces some complexity in figuring out exactly
how a Lambda function can invoke LibreOffice!

In the end, I decided to implement a very simple store and request
model. The client stores the document to a bucket shared between the
client and server and then explicitly tells the server to do
something.  This model only required a small Perl CGI that forks and
executes LibreOffice from the command line.  While a bit unsatisfying
from the elegance perspective it seems to do the trick reliably, if
not quickly.

While not sexy, it does support the use case I was actually interested
in.  My client creates a document in an S3 bucket for archival and
since I don't need the PDF or .png thumbnails right away, I'm not
necessarily interested in waiting around for the server to complete
those tasks.  It was sufficient for my client to store and request the
conversion.  And I might have some other tasks for the server to
perform on my files one day, so this model sort of made sense.

I note alternative architectures for files conversions in the event
someone out there has a niftier solution.

# Description

Behind the scenes, the document conversion process uses LibreOffice's
*headless* mode from the command line.  While you can apparently run
LibreOffice as a server in headless mode, my experience with that
method has not been all that positive, hence this HTTP based
conversion process pays the penalty of a **fork** and **exec** to
execute `soffice` from the command line.

Once you install the `doc-converter` RPM, take a peek at `man
doc-converter` for more details.  You can also take a look at
`/opt/libreoffice50/program/soffice --help` for more details on
converting documents.

# Reporting Bugs, Carping or Making Constructive Suggestions

Fire away: Rob Lauer - <rlauer6@comcast.net>

I would be especially interested in anyone that has figure out whether:

1. LibreOffice really can be used to support multiple connections
2. Has gotten the pyuno interface to work successfully and reliably
3. ...or has another method that makes more sense to create a reliable document creation service.

# Requirements

## Summary

- an EC2 instance running in a publicly available subnet
- an IAM role that has permissions to some bucket
- an S3 bucket
- LibreOffice 5
- RPM build tools (`rpm-build`)
- `automake`
- `autoconf`

## Details

### An EC2 Instance 

The server that is used for the document converter is assumed to be an
AWS EC2 instance prepared with the `libreoffice-doc-converter.json`
stack template.  A *CloudFormation template*
(`libreoffice-create-stack`) to create such a stack is
included as part of the `doc-converter-client` RPM.  To use the stack
creation script you'll want to make sure that:

* ...you're launching the stack in a subnet that has access to the
internet.  This is necessary so that the required assets can be
retrieved and installed.

* ...you take a look at the defaults defined in the CloudFormation
JSON template and make the necessary modifications or override them on
the command line when you run the `libreoffice-create-stack` bash
script.  Pay attention to these parameters in the template:

  * Subnet
  * Keyname
  * SecurityGroup
  * Role

* ...you have an IAM role configured that will allow your EC2 instance
and your client to read & write to an S3 bucket.  The bucket will be
used by your client and the `doc-converter` service to store
documents.  The policy for an appropriate IAM role might look like this:
```
 {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Sid": "Stmt1446041925000",
             "Effect": "Allow",
             "Action": [
                 "s3:ListAllMyBuckets"
             ],
             "Resource": "arn:aws:s3:::*"
         },
         {
             "Effect": "Allow",
             "Action": [
                 "s3:ListObjects",
                 "s3:GetObject",
                 "s3:PutObject",
                 "s3:DeleteObject",
                 "s3:ListBucket"
             ],
             "Resource": [
                 "arn:aws:s3:::mybucket",
                 "arn:aws:s3:::mybucket/*"
             ]
         }
     ]
 }
```
This policy will allow your EC2 instance, and hence the
`doc-converter` service to read and write to a specific directory (and
sub-directories) within your bucket.

See `libreoffice-doc-converter.json`.

See `libreoffice-create-stack`

Assuming you've defined an IAM role called `bucket-writer`, to create
an EC2 instance that will implement your document conversion service,
use the provided script that submits the CloudFormation stack for
creation. *To use the script you should have the AWS CLI tools installed.*

```
 $ libreoffice-create-stack -?

 $ libreoffice-create-stack -t /usr/share/doc-converter/libreoffice-doc-converter.json \
                            -i t2.micro \
                            -R bucket-writer \
                            -k mykey \
                            -u http://doc-converter.s3-website-us-east-1.amazonaws.com
```

### LibreOffice 5

The stack creation process mentioned above will grab a version of
LibreOffice 5 and install that during the instance creation.  The
LibreOffice 5 tar ball is retrieved from a known location (the last
known good location on the LibreOffice website) along with
other assets required to make this process work correctly.

*The location of these assets might change, so you might have to
modify the CloudFormation specification.  Again, it is suggested you
take a peek at the CloudFormation template.*

### Apache 2.2+

An Apache web server, listening on port 80 is also created as part of
the stack creation process.  An Apache configuration file is 
created and installed as:

`/etc/httpd/conf.d/doc-converter.conf`

There's nothing special about the configuration or the use of Apache.
It was just quick and convenient.  You can probably make the
`doc-converter.cgi` script work in other environments.

### `Amazon::S3`

A modified copy of the `Amazon::S3` Perl module is included in this
project.  I apologize in advance to those who are offended by the fact
that I did not simply push my change (send the session token in the
header) to that project, however that CPAN project appears to be
either deprecated or on life support in favor of more *modern*, but
far heavier versions of Perl S3 interfaces.

### LibreOffice Fixups

A Perl script, `fix-OOXMLRecalcMode` is executed as part of the stack
creation process.  It sets a LibreOffice configuration value so
spreadsheets are recalculated when they are loaded.  This is required
if you want your formulas in spreadsheets to be calculated before PDFs
are created.

### ghostscript fixups (Japanese Fonts)

Some issues have been identified when attempting to create .png file
from PDFs that require Japanese fonts.  I've pushed a fix to the
`/etc/ghostscript/8.70/cidfmap.local` file, however if you really are
using Japanese fonts, this fix may not work for you. YMMV.

# Getting Started

- If you want to merely create a new `doc-converter` server instance
read the section titled *Creating a Document Conversion Server*.

- If you want to hack on the project read the section titled *Hacking on
the Project*

## Creating a Document Conversion Server

You should be able to create a `doc-converter` instance by simply
installing the client package and creating the stack using the
included CloudFormation template.  The EC2 client from which you
create the stack should have the AWS CLI tools.

1. Setup the yum repository
2. Install the client package
3. Set your credentials
3. Submit the CloudFormation template

```
$ sudo yum-config-manager --nogpgcheck --add-repo http://doc-converter.s3-website-us-east-1.amazonaws.com
$ sudo yum --nogpgcheck -y install doc-converter-client
```

Make sure your AWS credentials are available either in your
`~/.aws/config` file or as environment variables.

```
$ libreoffice-create-stack -k mac-book -R mybucket -i t2.micro \
                           -t /usr/share/doc-converter/libreoffice-doc-converter.json

```

You should see some output put that looks something:

```
{
    "StackId": "arn:aws:cloudformation:us-east-1:106518701080:stack/libreoffice-doc-converter/287f64e0-8727-11e5-8263-50d5cd23c4c6"
}
```
Are we there yet, are we there yet?

```
$ aws cloudformation describe-stacks --region us-east-1 --stack-name libreoffice-doc-converter --query 'Stacks[0].StackStatus'
```

## Hacking on the Project

Hacking on the project means working with `autoconf`, `bash` and Perl
scripts.  If that makes your heart pump read on. Make sure you have
installed:

* `automake`
* `autoconf`
* `rpm-build`

To get started, download the project from GitHub, unzip it, and try to
build it.  You might have some success. If not, it's most likely some
toolchain issues you'll need to investigate.  It's not rocket
science though, so hang in there.


```
$ wget https://github.com/rlauer6/doc-converter/archive/master.zip
$ unzip master.zip
$ cd doc-converter-master
```

# Building an RPM

Building the project RPMs can be done using the `build` script
provided. Make sure you've installed `autoconf`, `automake`, and the
`rpm-build` packages and have a working RPM build directory.

```
$ mkdir -p ~/rpm/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
$ echo "%_topdir /home/ec2-user/rpm" > ~/.rpmmacros
```

Now give it a go to create the RPMs.

```
$ ./build
```

If you want to build the RPMs and install them to your own S3 bucket that
you've turned into a static website (and hence a yum repo), try this recipe.

```
$ aws s3 mb s3://mybucket
$ aws s3 cp index.html s3://mybucket/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
$ aws s3 website s3://mybucket/ --index-document index.html \
                                --error-document error.html
$ ./build mybucket
```

*This probably should not be the same bucket you use for document
conversion.*

The CloudFormation template to create your `doc-converter` server will
try to install the `doc-converter` RPM package from a repo.  In fact
it's the one that you specified using the -u option of the
`libreoffice-create-stack` script, so the above recipe might be useful
to you if you want to create a repo that can be accessed by the
CloudFormation template.


```
$ libreoffice-create-stack -k mac-book -R bucket-writer -i t2.micro \
                           -t /usr/share/doc-converter/libreoffice-doc-converter.json \
                           -u http://mybucket.s3-website-us-east-1.amazonaws.com
```

## Alternate Server Build Procedure

On the other hand you can just throw your hands up and say, "oh
bloody hell", and see what the dang CloudFormation template is trying
to do in that wonky `UserData` section and do it all by hand.

```
"UserData"           : { "Fn::Base64" : { "Fn::Join" : ["", [
    "#!/bin/bash -v\n",
    "\n",
    "# Helper function\n",
    "function error_exit\n",
    "{\n",
    "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '", { "Ref" : "WaitHandle" }, "'\n",
    "  exit 1\n",
    "}\n",
    "yum update -y\n",
    "# Install packages\n",
    "/opt/aws/bin/cfn-init -s ", { "Ref" : "AWS::StackId" }, " -r DocServer ", "-c Config ",
    "    --region ", { "Ref" : "AWS::Region" }, " || error_exit 'Failed to run cfn-init'\n",
    "\n",
    "# setup doc-converter repo and install package\n",
    "yum-config-manager --nogpgcheck --add-repo ", { "Ref" : "RPMUrl" },"\n",
    "yum install -y doc-converter\n",
    "# Adbobe Japanese font fix\n",
    "cat /usr/share/doc-converter/cidfmap.local >> /etc/ghostscript/8.70/cidfmap.local\n",
    "# download & install LibreOffice 5\n",
    "cd /tmp\n",
    "wget http://download.documentfoundation.org/libreoffice/stable/5.0.3/rpm/x86_64/LibreOffice_5.0.3_Linux_x86-64_rpm.tar.gz -P /tmp\n",
    "test -e LibreOffice_5.0.3_Linux_x86-64_rpm.tar.gz && tar xfvz LibreOffice_5.0.3_Linux_x86-64_rpm.tar.gz\n",
    "cd LibreOffice_5.0.3.2_Linux_x86-64_rpm/RPMS/\n", 
    "mv libobasis5.0-gnome-integration-5.0.3.2-2.x86_64.rpm libobasis5.0-gnome-integration-5.0.3.2-2.x86_64.rpm.sav\n",
    "rpm -Uvh *.rpm\n",
    "\n",
    "# set OO RecalcMode to true\n",
    "perl /usr/libexec/fix-OOXMLRecalcMode -i /opt/libreoffice5.0/share/registry/main.xcd -p\n",
    "chmod o+r /opt/libreoffice5.0/share/registry/main.xcd\n",
    "/sbin/service httpd restart\n",
    "\n",
    "/opt/aws/bin/cfn-signal -e 0 -r \"Setup complete\" '", { "Ref" : "WaitHandle" }, "'\n"
]]}}
```

In that case, you essentially need to do the following things:

1. Create an EC2 instance
2. Install all of the *Required* RPM packages as described in the `doc-converter.spec` file.
3. Install LibreOffice 5.0
4. Install the `doc-converter` package
5. Configure & restart Apache
6. Optionally apply patches to the LibreOffice config and ghostscript files

So, yeah, sure, you can do all those things manually, but the point of
all of this *automation* is so that you can create multiple instances
of the document converter.  You might want to create a load balanced
document conversion service someday. ;-)

# Using the Service

Assuming you've stuck with us so far, and you have an EC2 server
running, you'll want to try it out.

```
$ export DOC_CONVERTER_HOST=10.0.1.108
$ export DOC_CONVERTER_BUCKET=mybucket
$ /usr/libexec/doc2pdf-client test.xlsx

$ /usr/libexec/doc2pdf-client -h 10.0.1.108 -b mybucket test.xlsx

$ /usr/libexec/doc2pdf-client -t 70x90 -h 10.0.1.108 -b mybucket foo.doc

```

See `man doc2pdf-client` for more details.

# Finally...

I think you have enough clues to proceed, but if not, drop me a note.
