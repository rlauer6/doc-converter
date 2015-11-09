# README

This the README file for the `doc-converter` project.  The
`doc-converter` project implements an HTTP service for, among other
things, converting .xls[x] and .doc[x] documents to PDF.  The project
produces two RPMs:

- `doc-converter-1.0.0-0.rpm`
- `doc-converter-client-1.0.0-0.rpm`

...or some other versioned RPMs. Once more, this project's targets are
RPMs that you can then use to create a document conversion server and
client.  In other words, you build these RPMs then follow some
additional instructions in order to create the server.

If you don't want to create the RPMs you can try to download copies of
the RPMs (no guarantees that they will actually work however) from:

`https://doc-converter.s3-website-us-east-1.amazonaws.com`

# Description

Behind the scenes, the document conversion process uses LibreOffice's
*headless* mode in a command line fashion.  While apparently you can
run LibreOffice as a server in headless mode, my experience with
that method has not been all that positive, hence this HTTP based
conversion process pays the penalty of a fork and exec to execute
`soffice` from the command line.

Once you install the `doc-converter` RPM, take a peek at `man
doc-converter` for more details.  You can also take a look at
`/opt/libreoffice50/program/soffice --help` for more details on
converting documents.

# Reporting Bugs, Carping or Making Constructive Suggestions

Rob Lauer - <rlauer6@comcast.net>

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
- RPM build tools
  - `$ sudo yum install rpm-build`
- automake
- autoconf

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
                 "arn:aws:s3:::mybucket/doc-converter/*"
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
                            -u https://s3.amazonaws.com/doc-converter/doc-converter.1.0.0-0.noarch.rpm
```

### LibreOffice 5

The stack creation process mentioned above will grab a version of
LibreOffice 5 and install that during the instance creation.  The
LibreOffice 5 tar ball is retrieved from a known location (the last
known good location on the LibreOffice website) along with
other assets required for to make this process work correctly.

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

Make sure you have installed:

* automake
* autoconf
* rpm-build

To get started, download the project and run the bootstrap script.

```
$ wget https://github.com/rlauer6/doc-converter/archive/master.zip
$ unzip master.zip
$ cd doc-converter-master
$ ./bootstrap
```

# Building an RPM

Building the project RPMs can be done using the `build` script provided. Make
sure you've installed the `rpm-build` package and have a working RPM
build directory.

```
$ ./build
```

...or to build the RPMs and install them on in your S3 bucket...

```
$ ./build bucket-name
```

You'll want to install the RPMs in an accessible place so the
CloudFormation template can grab them during the stack creation.  You
specify where the RPMs were installed using the -u option of the
`libreoffice-create-stack` script.

```
$ libreoffice-create-stack -k mac-book -R bucket-writer -i t2.micro \
                           -t /usr/share/doc-converter/libreoffice-doc-converter.json \
                           -u https://s3.amazonaws.com/mybucket/doc-converter-1.0.0-0.noarch.rpm
```

On the other hand you can just throw your hands up and so say, "oh
bloody hell", and see what the dang CloudFormation template is trying
to do in that wonky UserData section and do it all by hand.

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
    "# download LibreOffice 5, etc.\n",
    "cd /tmp\n",
    "wget ", { "Ref" : "RPMUrl" }," /tmp\n",
    "yum install -y /tmp/doc-converter-1.0.0-0.noarch.rpm\n",
    "wget http://download.documentfoundation.org/libreoffice/stable/5.0.3/rpm/x86_64/LibreOffice_5.0.3_Linux_x86-64_rpm.tar.gz -P /tmp\n",
    "cat /usr/share/doc-converter/cidfmap.local >> /etc/ghostscript/8.70/cidfmap.local\n",
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

In that case, you need to do the following things:

1. Create an EC2 instance
2. Install the *necessary* RPM packages as described in the `doc-converter.spec` file.
3. Install LibreOffice 5.0
4. Install the `doc-converter` package
5. Configure & restart Apache
6. Apply patches to the LibreOffice config and ghostscript files

Sure, you can do all those things manually, but the point of all of
this *automation* is so that you can create multiple instances of the
document converter.  You might want to create a load balanced document
conversion service.
