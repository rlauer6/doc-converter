# README

This is the README file for the `doc-converter` project.  The
`doc-converter` project implements an HTTP service, architected to run
in the Amazon AWS envrironment, for among other things, converting
.xls[x] and .doc[x] documents to PDF.  This project will produce three
RPMs:

- `doc-converter-1.0.0-0.rpm`
- `doc-converter-client-1.0.0-0.rpm`
- `doc-converter-utils-1.0.0-0.rpm`

...or some other versioned RPMs. Just to be clear, this project's
targets are RPMs that you can then use to create a document conversion
server and client.  In other words, you build these RPMs then follow
some additional instructions in order to create the server.

If you don't want to create your own customized RPMs you can try
to install the RPMs (no guarantees that they will actually work for you
however) from the quasi-official `doc-converter` yum repository:

```
[doc-converter]
baseurl=http://doc-converter.s3-website-us-east-1.amazonaws.com
name=doc-converter
gpgcheck=0
enabled=1
```

...or if you want to descend into the hell that is
`yum-config-manager` (hint: it is *very* buggy), then try this:


```
$ sudo yum-config-manager --add-repo http://doc-converter.s3-website-us-east-1.amazonaws.com
$ sudo yum-config-manager --save --setopt 'doc-converter.s3-website-us-east-1.amazonaws.com.name=doc-converter' 
$ sudo yum-config-manager --save --setopt 'doc-converter.s3-website-us-east-1.amazonaws.com.gpgcheck=0'

$ sudo yum -y install doc-converter
$ sudo yum -y install doc-converter-client
```

*P.S. The reason for setting `name` in the repo config file is so
`yum-config-manager` will add the `gpgcheck` option.  No attempt to set
`gpgcheck` with out first having `gpgcheck` in the file was successful
until I hit upon this work around.*

Once you install the `doc-converter-client` RPM I highly encourage you
to read the man page for the document conversion client.

```
 $ man doc2pdf-client
```

# `doc-converter` Architecture

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

Your clients push documents to your S3 bucket (more on permissions
you'll need for your bucket later) and then request a conversion
service by making a request to an HTTP endpoint.  The server then
reads the bucket and converts the documents.  The client can then
retrieve the PDF and/or .png files from the S3 bucket.

## Architectural Considerations and Alternatives

On possible way to implement this service takes advantage of the fact
that S3 buckets can be configured to generate various events when
objects are modified.  The S3 service can generate:

1. an SQS notification
2. an SNS notification
3. a Lambda event

In the the first two scenarios, we would need some sort of subscriber
to those events, either a message queue handler of some kind that
reads the SQS queue and processes the events or an endpoint that
handles SNS notifications and takes an appropriate action.  In either
case, we would need to provision an EC2 instance to run our code.

*Scenario 3* is clearly more appealing.  That is, create a Lambda
function that responds to the S3 event and then performs some magic on
the documents.  While this appears a bit more appealing
architecturally, it introduces some complexity in figuring out exactly
how a Lambda function can invoke LibreOffice!

In the end, I decided to implement a very simple store and request
model. The client stores the document to a bucket shared between the
client and server and then explicitly tells the server to do
something.  This explicit request, which can be made by the client
after the document is pushed to the shared S3 bucket, is low-cost (as
in nearly zero) as compared to generating an event placed on a queue
that will need to be read at some frequency.  SQS reads have a cost,
albeit very small.  However if you plan on running your service
24x7x365 you'll be probably be doing a lot of reads that come up
empty.

The store and request model only requires a small Perl CGI that forks and
executes LibreOffice from the command line.  While a bit unsatisfying
from the elegance perspective it seems to do the trick reliably, if
not quickly.

While not sexy, it does support the use case I was actually interested
in.  My client creates a document in an S3 bucket for both potentially
immediate needs and for archival requirements.  In general I might not
need the PDF or .png thumbnails right away so I'm not necessarily
interested in waiting around for the server to complete those tasks.

In that case it would be sufficient for my client to store the file to
S3 and then just request the conversion.  Of course, I could opt to
wait for the conversion as well.  YMMV.

I note alternative architectures for file conversions in the event
someone out there has a niftier solution.

# Description

Behind the scenes, the document conversion process uses LibreOffice's
*headless* mode from the command line.  While you can apparently run
LibreOffice as a server in headless mode, my experience with that
method has not been all that positive (concurrency issues that will
eventually crash LibreOffice - a bug has been filed against LO and
this may in fact be fixed in 5.2) , hence this HTTP based conversion
process pays the penalty of a **fork** and **exec** to execute
`soffice` from the command line.

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
- an S3 bucket that is readable and writable by both the client and
  the server.  This can be achived using an IAM role that you can
  assign to both the client and server instance
- LibreOffice 5
- RPM build tools (`rpm-build`)
- `automake`
- `autoconf`
- `rpm-build`

## Details

### An EC2 Instance 

The server that is used for the document converter is assumed to be an
AWS EC2 instance prepared with the `libreoffice-doc-converter.json`
CloudFormation stack template.

A *CloudFormation template* (`libreoffice-create-stack`) to create
such a stack is included as part of the `doc-converter-client` RPM.
To use the stack creation script you'll want to make sure that:

* ...you're launching the stack in a subnet that has access to the
internet.  **This is necessary so that the required assets can be
retrieved and installed.**

* ...you take a look at the defaults defined in the CloudFormation
JSON template and make the necessary modifications or override them on
the command line when you run the `libreoffice-create-stack` bash
script.  Pay attention to these parameters in the template:

  * Subnet
  * Keyname
  * Role
  * Instance Type

```

usage: libreoffice-create-stack [options]
       -e echo only - just echo the command
       -h|? this
       -i instance type (ex: t2.micro)
       -I AMI (defaults to: ami-e3106686
       -k keyname
       -L LibreOffice version (5.1.0)
       -l LibreOffice release (3)
       -n server name (defaults to 'libreoffice-doc-converter')
       -R role name (defaults to EC2 instance role)
       -r region (defaults to us-east-1)
       -S subnet (no default - required)
       -s stack name (defaults to 'libreoffice-doc-converter')
       -t template (defaults to 'libreoffice-doc-converter.json')
       -v validate template only
       -u url for the doc-converter RPM repo
```

* ...you have an IAM role configured that will allow your EC2 server instance
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
 $ libreoffice-create-stack -h

 $ libreoffice-create-stack -i t2.micro \
			    -L 5.1.0 \
                            -l 3 \
                            -R bucket-writer \
                            -k mykey \
                            -S subnet-932594e4
```

**NOTE: YOU MUST HAVE PERMISSIONS TO ACTUALLY CREATE EC2 INSTANCES AND
OTHER ASSETS IN ORDER TO RUN THE STACK CREATION SCRIPT.**

### Network Considerations

#### Subnet

The stack has to be launched in a subnet, but which one?  The stack
will not create it's own network or subnet, so you must provide the
subnet id.  The script will determine the VPC that you are launching
into by looking at the subnet id.  If you aren't using a VPC, then
you'll have to muck with the CloudFormation script and work that out
for yourself.  You should be using a VPC ;-)

#### Security Group

By default the stack will create it's own security group.  It will
open up ingress to ports 80 and 22 only.  You should make sure that
you are launching the instance in a public subnet that has access to
the internet.  An external public IP is provisioned by default.  If
you want to launch your server in a private subnet, you can, but your
instance still must have access to the internet via a NAT or gateway
otherwise the instance will not be able to access the resources (rpms)
it needs to configure itself.

If you do not want to provision an external IP, then set the
PublicIpEnabled value to "false".  If you want just want to block
in-bound traffic but still want your server in a Public subnet, then
you might want to change the ingres rules.

```
"SecurityGroupIngress" : [
    {
	"IpProtocol" : "tcp",
	"FromPort" : "80",
	"ToPort" : "80",
	"CidrIp" : "10.0.1.0/16"
    },
    {
	"IpProtocol" : "tcp",
	"FromPort" : "22",
	"ToPort" : "22",
	"CidrIp" : "10.0.1.0/16"
    }]
```

Here, I'm only allowing traffic from within my 10.0.1.0/16 subnet to
access my server.

### LibreOffice 5

The stack creation process mentioned above will grab a version of
LibreOffice 5 and install that during the instance creation.  The
LibreOffice 5 tar ball is retrieved from the LibreOffice website using
the last known good location based on the desired version. The
LibreOffice version that is downloaded by default is 5.1.0 release 3.
The process thinks the tarball for that release might be found at
`http://download.documentfoundation.org` as
`LibreOffice_5.1.0_Linux_x86-64_rpm.tar.gz`.  And that may in fact be
true, but you can try playing with the options in the -L and -l
options of the `libreoffice-create-stack` script if you want a
different version of LibreOffice or it has moved since this release.

Take a look at the `libreoffice-download` script to see how it attepts
to download and eventually install LibreOffice if the stack creation
process is failing for you.

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
4. Submit the CloudFormation template

or

1. Setup the yum repository
2. Install the client package
3. Use the AWS console to configure the CloudFormation template

The template can be found here:

 http://doc-converter.s3.amazonaws.com/libreoffice-doc-converter.json


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

If your default region was the us-east-1, then you can visit:

 http://mybucket.s3-website-us-east-1.amazonaws.com

...and then you might want to configure the yum repository:

```
$ sudo yum-config-manager --add-repo http://mybucket.s3-website-us-east-1.amazonaws.com
$ yum --disablerepp="*" --enablerepo="mybucket.s3-website-us-east-1.amazonaws.com" list available 
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
$ libreoffice-create-stack -k mac-book -R bucket-writer -i t2.micro 
                           -t /usr/share/doc-converter/libreoffice-doc-converter.json \
                           -u http://mybucket.s3-website-us-east-1.amazonaws.com
```

## Alternate Server Build Procedure

On the other hand you can just throw your hands up and say, "oh
bloody hell", and see what the dang CloudFormation template is trying
to do in that wonky `UserData` section and do it all by hand.

```
     1	"UserData"           : { "Fn::Base64" : { "Fn::Join" : ["", [
     2	    "#!/bin/bash -v\n",
     3	    "\n",
     4	    "# Helper function\n",
     5	    "function error_exit\n",
     6	    "{\n",
     7	    "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '", { "Ref" : "WaitHandle" }, "'\n",
     8	    "  exit 1\n",
     9	    "}\n",
    10	    "yum update -y\n",
    11	    "# Install packages\n",
    12	    "/opt/aws/bin/cfn-init -s ", { "Ref" : "AWS::StackId" }, " -r DocConverter ", "-c Config ",
    13	    "    --region ", { "Ref" : "AWS::Region" }, " || error_exit 'Failed to run cfn-init'\n",
    14	    "\n",
    15	    "# setup doc-converter repo and install package\n",
    16	    "yum-config-manager --nogpgcheck --add-repo ", { "Ref" : "RPMUrl" },"\n",
    17	    "yum install --nogpgcheck -y doc-converter\n",
    18	    "# Adbobe Japanese font fix\n",
    19	    "cat /usr/share/doc-converter/cidfmap.local >> /etc/ghostscript/8.70/cidfmap.local\n",
    20	    "# download & install LibreOffice 5\n",
    21	    "/usr/bin/libreoffice-download -r ",{ "Ref" : "LoRelease"}, " -v ", {"Ref" : "LoVersion"}, " || error_exit 'LibreOffice download error'\n", 
    22	    "/sbin/service httpd restart\n",
    23	    "\n",
    24	    "/opt/aws/bin/cfn-signal -e 0 -r \"Setup complete\" '", { "Ref" : "WaitHandle" }, "'\n"
```

In that case, you essentially need to do the following things:

1. Create an EC2 instance
2. Install all of the *Required* RPM packages as described in the `doc-converter.spec` file.
3. Install the `doc-converter` package (lines 16,17)
4. Optionally apply patches to the ghostscript files to handle Japanese fonts (line 19)
5. Install LibreOffice 5.1 (line 21)
6. Restart Apache

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

# Oh Yeah, GUIDs

The `doc-converter` service URI requires a document id which is, in fact a GUID.

https://en.wikipedia.org/wiki/Globally_unique_identifier

Your documents should be stored in the S3 bucket with a prefix that
consists of the GUID (8+4+4+4+12).  The included client,
`doc2pdf-client`, uploads documents to the bucket and creates a new
document identifier for you.

Example GUID:

```
3F2504E0-4F89-41D3-9A0C-0305E82C3301
```

# Finally...

I think you have enough clues to proceed.  Don't forget to read the man pages.

- `$ man doc2pdf-client`

- `$ man doc-converter`

If all else fails, drop me a note.
