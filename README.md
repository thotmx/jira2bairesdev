# jira2bairesdev
A simple script to import JIRA Tempo timesheets to BairesDev TimeTracker

Steps to run:

```
bundle install
```

Rename the config template:

```
mv config.yml.template config.yml
```

Add your configuration options.

Download the .xls from JIRA and put them into the directory that you set on the config.yml file.

**Important**: Be careful about not repeating the files because currently avoiding duplicates is not supported yet.

Then run and let the magic happens.

```
bundle exec ruby lib/run.rb
```

This is a working first approach. There is a lot of work to improve it.
