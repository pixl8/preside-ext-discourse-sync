component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		settings.filters.topLevelDiscourseCategories = { filter="parent_category is null" };
	}
}
