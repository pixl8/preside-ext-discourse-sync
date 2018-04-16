/**
 * @versioned                    false
 * @datamanagerGroup             discourse
 * @datamanagerAllowedOperations read
 * @datamanagerGridFields        id,name,parent_category
 * @labelfield                   name
 */
component {
	property name="id"          type="numeric" dbtype="int" generator="none";
	property name="name"        type="string"  dbtype="varchar" required=true;
	property name="description" type="string"  dbtype="varchar" maxlength=800;
	property name="topic_url"   type="string"  dbtype="varchar";
	property name="color"       type="string"  dbtype="varchar";
	property name="text_color"  type="string"  dbtype="varchar";

	property name="parent_category" relationship="many-to-one" relatedto="discourse_category";
}