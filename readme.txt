Metro (0.6)

What is Metro?
=============
Metro is a library of components to support rapid development of applications that use ColdSpring and Transfer ORM. 

Impetus
=======
While developing projects with Transfer over the course of the past year, I've noticed a repetition 
in the application model code that led me to adopt some basic conventions thereby actively generating
much of the code I would have created with passive code generation.  Convention based code 
generation will only get you so far, there are nuances to an application model that are difficult to 
achieve with code generation.  To hedge this, Metro makes it easy to define concrete components 
(services or gateways) that extend the core Metro components, so one can write custom code to override
and/or augment the actively generated code.

Conventions
===========
The over-reaching convention for metro is the concept of packaging related object so that they are managed 
by a single service.  As an example, Metro includes a security package with simple User, Role and Permission
objects that are managed by a single UserService composed with a gateway for each object.  To achieve this,
Metro parses the transfer XML configuration into a simplified config structure.   

API
===
A service created by the Metro ServiceFactory provides get(), new(), list(), save() and delete() methods for objects
under a given package.  For example, the security package included in metro contains three objects: User, Role and
Permission.  One can use get("objectName") or get{objectName}(), etc. for each object managed by the service. The
syntactic sugar of get{objectName}() is achieved through onMissingMethod.

Setup
=====
Metro is setup using ColdSpring and Transfer.  You'll find a sample Coldspring bean definitions file in the tests/config
folder.  The Metro ServiceFactory accepts 5 constructor arguments.

1. TransferConfig (required) - The transfer configuration object.
2. BeanInjector (required) - The beanInjector found in the metro.lib package.
3. componentPath (optional) - The base component path in your application where each package can be found.
4. libPath (optional) - The base component path in your application where each package can be found.
5. afterCreateMethod (optional) - A method to call on Services or Gateways created by the ServiceFactory


Requirements
============
- Transfer (tested against 1.1)
- ColdSpring (tested against 1.2)

Installation and Testing
========================
To see Metro in action, follow the directions below.

1. place metro in web root
2. create a database and run the database schema files located in /metro/docs/sql/ (choose either mssql or mysql)
3. create a datasource "metro-security" pointing to the database
4. run mxunit tests under metro/tests

Acknowledgments
===============
A big thanks to Mark Mandel (http://www.compoundtheory.com), Bob Silverberg (http://www.silverwareconsulting.com) and
Matt Quackenbush (http://www.quackfuzed.com) for advice and guidance, and to Brian Kotek (http://www.briankotek.com/blog/)
for approving the inclusion of his BeanInjector and TDOBeanInjectorObserver components in the library.


History
=======
2008-12-07 - (0.1) Initial release.
2008-12-08 - (0.1.1) Fix bug in core.Gateway to handle retrieving objects with composite ids.
2008-12-18 - (0.2)	Re-factor core.Gateway and core.Service to remove PK naming convention. 
					Add CSS file and rename jQuery plugin.
2009-01-04 - (0.3)	Add audit package.
					Update core Service and Gateway to add getByProperty() support
					Fix bug in core Decorator related to validation rule creation.
					Update security package to add "Active" attribute to User.
					Update css to add classes.
2009-01-08 - (0.3.1) Re-factor Audit class, AuditObserver and sql into security package
					 Remove audit package.
					 Added hints to components, methods and arguments.
					 Updated Tests configuration to create Audit Observer.
					 ServiceFactory now supports creation of concrete classes that extend metro.core.Service and metro.core.Gateway recursively
					 which means you can write a concrete class that extends metro.security.SercurityService
2009-01-09 - (0.3.2) ServiceFactory now supports defining concrete gateways without requiring a concrete service in the same package.
					 If no concrete package is defined in the component root or within the Metro library, the service and gateways returned
					 will extend the Metro core components.  The ServiceFactory will throw an error if the package name is not found in the Transfer
					 object definitions.
					 Added optional libPath constructor argument to the ServiceFactory.
2009-01-22	- (0.4)  Split Security package into User and Security packages.
					 modified hasPermission method on UserDecorator to accept comma separated list of permissions to check.
					 fix inconsistencies in generic Cache object
2009-01-23	- (0.4.1) Bug fix to ServiceFactory to avoid throwing an error when component and lib paths are empty strings
2009-02-07	- (0.5) Added CompositeId support (contributed by Bob Silverberg)
					Added tests for core Gateway and Validator components
					Added work package as a test bed for compositeids
2009-02-22	- (0.6) Significant update to ServiceFactory configuration and core component construction to leverage autowiring where possible.
					Re-organization of component packages and support documents.
2009-02-25	- (0.6.1) Updates to Decorator, Validator and User classes for error handling
2009-03-02	- (0.6.2) Small update to User class and test
2009-03-11	- (0.7)	Added 'reap' method to Service and Gateway to discard class (by key when provided) from transfer cache.
					Cleanup on model decorators rules declarations.
					Added methods to UserService.
					Fix MySQL user schema.
2009-03-19	- (0.8)	Added transaction safe create() and update() methods to core Service.  Each method returns a Transfer object.
					Minor updates to tests.
					Fix bug in User.login() method - now uses clone for testing valid login.
2009-04-10	- (0.8.4)	Update core Service list() method to support custom paged queries
						Moved classes map for TransientFactory to a MapfactoryBean.
						Remove save() method from core Decorator.
2009-04-27	- (0.9) Update TransferAuditObserver to allow specifying a target method to invoke for after a class is created or updated, or before delete.
					Some other minor updates to prepare for Railo 3.1 compatibility.
2009-06-21	- (0.9.1) Adapted a simple Recordset within the metro core.  