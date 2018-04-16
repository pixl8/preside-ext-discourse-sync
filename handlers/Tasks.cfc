component {

	property name="discourseTopicSyncService" inject="discourseTopicSyncService";

	/**
	 * Gathers statistics from the system and sends them to Zabbix
	 *
	 * @displayName  Sync in categories from discourse
	 * @displayGroup Discourse
	 * @schedule     0 *\/20 * * * *
	 * @priority     10
	 * @timeout      600
	 *
	 */
	private boolean function syncDiscourseCategories( event, rc, prc, logger ) {
		return discourseTopicSyncService.syncCategories( logger=arguments.logger ?: NullValue() );
	}
}
