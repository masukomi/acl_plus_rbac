# acl\_plus\_rbac


NOTE: This Rails Plugin was last touched in 2006. It needs to be tested,
and updated, to work with Rails 3.x and add caching to reduce the number 
of queries required to perform the rather complex authorization schemes
that it supports. As far as I know no other plugin that supports both 
Access Control Lists and Roles Based Authorization.


## Authorization vs. Authentication
Authentication lets you determine that a user is who they claim to be. The most common usage is used to determine if a user can even log in to a system. Authorization controls what that user can do once it's been determined that the user 
is even allowed in. acl_plus_rbac is authentication system agnostic. Use it with acts_as_authenticated or any other authentication system. It doesn't care. You just need to add a few lines to the User class of your favorite authentication system to connect it to groups, roles, and permissions.

## BIG PRINT FOR THE SKIMMERS:

## THIS WILL NOT AUTHENTICATE USERS OR CONTROL A USER'S ABILITY TO LOG IN IN ANY WAY.

However, because there's no point in authorization without authentication this plugin assumes you will be using an authentication system and requires a pre-existing User class. My recommendation is that you install an authentication system like restful\_authentication before installing acl\_plus\_rbac.


## Role Based Access Control


Role Based Access Control (wikipedia article) is a great tool but it is based on the idea that you're limiting access to 
types of things or actions not individual things. Imagine you have a system with lots of company records in it. Some people can edit them, some people can just view them, some people can't see them at all. But there's no good way to mark one of those company records as being visible/editable to a specified group of people if you're just using RBAC.

A Role is equivalent to a job function. Each Role has associated permissions. A newspaper has Roles like:

* Editor in Chief (can edit, approve, or reject anything)
* Sports Editor (can edit, approve, or reject anything in the sports section)
* Writer (can only write new articles and edit articles they wrote)

The Sports Editor may also have the Role of Writer which would mean that they get to write new articles and approve them if they're for the sports section.

----

## Access Control Lists

Access Control Lists (wikipedia article) are great at limiting visibility of individual items to individuals or groups 
but are fairly restricted in their ability to control what specific people do with / to an item they have permission to see. In the \*nix world it can only control your ability to read, write, and / or execute something. If you apply this to something like a company record there's no way to indicate that a person who can see the company can't edit the company name but can edit the phone number unless every single component of that company is a separate record with separate ACLs. This could lead to a LOT of database calls.


## WHAT THIS PLUGIN DOES

acl\_plus\_rbac combines the ideas of ACL an RBAC in the following way:

* Any record in your system can have an associated ACL
* Each ACL is used to grant access to that record to one user and any number of groups. The user is usually the records creator.
* If the creator, or a member of one of the groups indicated by the ACL, or one of their sub-groups, tries to access an object you can then use the RBAC system to determine what they can do with it.
* Groups of users can have sub-groups and parent groups.
* Groups of users can have roles associated with them.
* Users can have roles associated with them.
* Roles can have any number of permissions associated with them.
* You can query a UserGroup to see if its roles grant a specific permission.
* You can query a User to see if they have a specific permission granted to them through any of their Roles or any of the Roles associated with any of the Groups they belong to or any of their Groups parent Groups.
* You can query a Role to see if it grants a specific permission.

The best way to use a system like this is to create ACL records for container objects. For example: A company is really a container for many other records like phone numbers, addresses, notes, files, contact people, etc. When someone requests access to a company record pull up it's ACL and see if that user is the creator or a member of one of the approved groups. If not you can just give them a permission denied message. If they are you can first use the RBAC system to determine which types of containing objects they have permission to view. If they can't see notes then you don't need to bother to load them in the controller. In the view you can then determine if you should render an edit button for the notes or a delete button for the files. In most systems there's no need to test every single associated object to see if the user can see it. If they can see the company record they can usually either see all of the notes or none of the notes.


Further Details are available in the docs/index.html file.
