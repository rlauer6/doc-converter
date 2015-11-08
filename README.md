This the README file for the `doc-converter` project.  The
`doc-converter` project implements an HTTP service for, among other
things, converting .xls[x] and .doc[x] documents to PDF.  The project
produces two RPMs:

 doc-converter-1.0.0-0.rpm
 doc-converter-client-1.0.0-0.rpm

...or some other versioned RPMs.

The document conversion process uses LibreOffice's "headless" mode in
a command line fashion.  Yes, I know you can run this as a server, but
my experience with that has not been positive.

See `man doc-converter` for more details.

See `/opt/libreoffice50/program/soffice --help` for more details on
converting documents.


Bugs/Carps/Suggestions
======================

Rob Lauer - <rlauer6@comcast.net>


Requirements
============

Summary:

 - an EC2 instance
 - an S3 bucket
 - LibreOffice 5

http://download.documentfoundation.org/libreoffice/stable/5.0.3/rpm/x86_64/LibreOffice_5.0.3_Linux_x86-64_rpm.tar.gz


An EC2 Instance 

  The server that is used for the document converter is assumed to be
  an AWS EC2 instance prepared with the
  `libreoffice-doc-converter.json` stack template.  A CloudFormation
  script to create such a stack is included as part of the
  `doc-converter-client` RPM.  To use the stack creation stack you'll
  want to make sure that:

  1. You have an IAM role configured that will allow your EC2 instance
     to read & write to an S3 bucket.  The bucket will be used by
     your client and the doc-converter server to store documents.  The
     policy for an appropriate role might look like this:

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
                     "arn:aws:s3:::treasurersbriefcase-development",
                     "arn:aws:s3:::treasurersbriefcase-development/doc-converter/*"
                 ]
             }
         ]
     }

     This policy will allow your EC2 instance, and hence the
     doc-converter service to read and write to a specific directory
     within your bucket.

  See `libreoffice-doc-converter.json`.

  See `libreoffice-create-stack`

    $ libreoffice-create-stack -t /usr/share/doc-converter/libreoffice-doc-converter.json \
                               -i t2.micro \
                               -R bucket-writer

    $ libreoffice-create-stack -?

LibreOffice 5   

  The stack creation process mentioned above will grab a version of
  LibreOffice 5 shown to work and install that during instance
  creation.  The LibreOffice 5 tar ball is retrieved from a known
  location along with other assets required for to make this process
  work correctly:

    s3://treasurersbriefcase-development/doc-converter

Apache 2.2+

  An Apache web server, listening on port 80 is also created as part
  of the stack creation process.

  A small configuration file is also created and installed as:

    /etc/httpd/conf.d/doc-converter.conf

  Feel free to edit/rename as you see fit.


Additional Requirements
=======================

Amazon::S3

A modified copy of the Amazon::S3 Perl module is included in this
project.


LibreOffice Fixups
==================

Japanese Fonts - some issues have occurred creating .png files from
PDFs that require Japanese fonts.

OOXMLRecalcMode - sets LibreOffice so spreadsheets are recalculated on
load.  This is required if you want your formulas to be calculated.
