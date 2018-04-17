component {

	property name="discourseTopicSyncService" inject="discourseTopicSyncService";

	/**
	 * Syncs all categories from Discourse into the website
	 *
	 * @displayName  Sync in categories from discourse
	 * @displayGroup Discourse
	 * @schedule     0 *\/20 * * * *
	 * @priority     100
	 * @timeout      600
	 *
	 */
	private boolean function syncDiscourseCategories( event, rc, prc, logger ) {
		return discourseTopicSyncService.syncCategories( logger=arguments.logger ?: NullValue() );
	}

	/**
	 * Syncs topics from Discourse into the website
	 *
	 * @displayName  Sync in topics from discourse
	 * @displayGroup Discourse
	 * @schedule     0 *\/20 * * * *
	 * @priority     50
	 * @timeout      600
	 *
	 */
	private boolean function syncDiscourseTopics( event, rc, prc, logger ) {
		return discourseTopicSyncService.syncTopics( logger=arguments.logger ?: NullValue() );
	}
}
