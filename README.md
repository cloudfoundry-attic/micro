VMware Micro Cloud Foundry

This repository contains build scripts, the console application, the REST API
and the web GUI for the Micro Cloud Foundry.

API
===

The Micro Cloud has a hypermedia/REST API. Starting at the root resource, each
resource is exposed via named links in the _links element. The links give the
client the expected HTTP method, URL and content type for each state.

Clients should start at the root and navigate through links for each request.
They should use the methods, URLs and content types that are returned and
not build any URLs themselves.

The API is browsable using a browser with a JSON formatting plugin like
JSONView installed.

API Capabilities
================

Set HTTP proxy
--------------

/ edit link / send request with http_proxy set

Enable disable internet connection (offline mode)
-------------------------------------------------

/ edit link / send request with internet_connected = true or false

Power off VM
------------

/ edit link / send request with is_powered_on = false

Set administrator email
-----------------------

/ administrator link / edit link / send request with email field set

Set administrator password
--------------------------

/ administrator link / edit link / send request with password field set

Set domain to a domain name
---------------------------

/ domain_name link / edit link / send request with name field set

Set domain using a token from cloudfoundry.com
----------------------------------------------

/ domain_name link / edit link / send request with token field set

Refresh DNS
----------

Update the Micro Cloud DynDNS hostname with the VM's current IP address.

/ domain_name link / edit link / send request with synched = true

Configure the network interface statically
------------------------------------------

/ network_interface link / edit link / send request with ip_address, netmask,
gateway and nameservers set

Configure the network interface to use DHCP
------------------------------------------

/ network_interface link / edit link / send request with is_dhcp = true

Start or stop a service
-----------------------

/ services link / select service by name and follow edit link / send request
with enabled = true or false

API Architecture
================

Media Types
-----------

Each resource has a media type class that is a subclass of Engine::MediaType.
Subclasses define a MediaType class constant for their content type and a
set of links to other resources.

Links
-----

The format of the links in JSON is based on the link format of HAL with a few
additions: http://stateless.co/hal_specification.html

Serialization and Content Types
-------------------------------

The MediaTypeSerial Rack middleware automatically parses incoming JSON
into the correct MediaType subclass based on its content type. The
media type object is set as env['media_type_object'] in Rack environment.

This middleware also serializes MediaType subclasses to JSON based on their
instance variables and sets the correct content type on responses.

Routes
------

Classes in the Routes module are automatically registered in the Sinatra
app.

Code Organization
-----------------

The Engine module is intended for generic hypermedia API code that might
eventually be moved to a separate project.
