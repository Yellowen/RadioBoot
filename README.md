RadioBoot Official website
==========================

A web application to manage and publish podcasts based on **Sinatra** web framework, tuned to use with
**openshift**

Running on OpenShift
--------------------

Create an account at https://www.openshift.com

Create a ruby application

    rhc app create sinatra ruby-1.9 --from-code https://github.com/Yellowen/RadioBoot.git

That's it, you can now checkout your application at

    http://sinatra-$yournamespace.rhcloud.com


Running this application locally
----------------------------------

Before running any of these examples, you should run the below command to make sure that you have the correct ruby gems installed

		bundle install

To run this application locally, cd into the sinatra-example directory that you cloned and run

		bundle exec rerun 'rackup -p 3000'

It's simply a **Sinatra** app nothing special

License
-------
This application release under the term of GPLv2.
