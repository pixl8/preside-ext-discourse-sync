# Discourse topic sync for Preside

This extension connects a discourse instance and syncs topics into your Preside application. From here you can index topics to build an integrated solution with discourse and your Preside website.

## Installation

From a commandline at the root of your application: 

```
box install preside-ext-discourse-sync
```

## Configuration

Once installed, login to the Preside admin and head to **System -> Settings -> Discourse Sync Credentials**. 

Enter your discourse base URL, e.g. https://community.preside.org, the API key that you generate within the Discourse admin and a Discourse username that all API requests will be authenticated with (make sure that user has permissions to get the data you need!). Save these settings.

Head over to **System -> Task manager** and find the discourse sync tasks. Run the **Sync categories** task to pull down all the categories from Discourse. If you want to limit the topics that you sync to certain categories, then head back to the discourse settings page and choose the categories that you want.

Finally, run the **Sync topics** task to sync down any topics you want in your system.

## Usage

What you do with the data is now up to you! You could create a page type that lists topics that are filtered by a rules engine filter, or create widgets that do the same thing. All up to you :)

## Contributing

Pull requests, issues and ideas are all welcome :) Please use Github or get in touch with the Preside team on our [Preside Slack](https://presidecms-slack.herokuapp.com/).




