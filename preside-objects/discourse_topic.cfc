/**
 * @versioned                    false
 * @datamanagerGroup             discourse
 * @datamanagerAllowedOperations read
 * @datamanagerGridFields        id,title,created_at,last_posted_at
 * @labelfield                   title
 */
component {
	property name="id"             type="numeric" dbtype="int" generator="none";

	property name="title"          type="string"  dbtype="varchar"  required=true;
	property name="topic_url"      type="string"  dbtype="varchar"  required=true;
	property name="created_at"     type="date"    dbtype="datetime" required=true;
	property name="last_posted_at" type="date"    dbtype="datetime" required=false;

	property name="excerpt"        type="string"  dbtype="text";
	property name="image_url"      type="string"  dbtype="varchar";
	property name="visible"        type="boolean" dbtype="boolean" default=false;
	property name="liked"          type="boolean" dbtype="boolean" default=false;
	property name="views"          type="numeric" dbtype="int" default=0;
	property name="posts_count"    type="numeric" dbtype="int" default=0;
	property name="reply_count"    type="numeric" dbtype="int" default=0;
	property name="like_count"     type="numeric" dbtype="int" default=0;

	property name="author"   relationship="many-to-one" relatedto="discourse_user";
	property name="category" relationship="many-to-one" relatedto="discourse_category";
}
