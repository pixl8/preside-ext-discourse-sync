/**
 * @versioned                    false
 * @datamanagerGroup             discourse
 * @datamanagerAllowedOperations read
 * @datamanagerGridFields        id,name
 * @labelfield                   name
 */
component {
	property name="id"             type="numeric" dbtype="int" generator="none";

	property name="name"            type="string"  dbtype="varchar" required=true;
	property name="username"        type="string"  dbtype="varchar" required=true;

	property name="avatar_template" type="string"  dbtype="varchar";
	property name="post_count"      type="numeric" dbtype="int" default=0;
}