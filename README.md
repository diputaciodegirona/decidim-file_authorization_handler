# Decidim File Authorization Handler

> A plugin to add a csv based authorization handler to the Decidim platform

Allows admin users to upload a CSV file containing Document IDs and birthdates 
to a given organization.
This information is used by a Decidim authorization handler to authorize real 
users.

## Usage

This module provides a model `Decidim::FileAuthorizationHandler::CensusDatum` 
to store census information (identity document and birth date) in a hashed way
(real data is never stored).

It has an admin controller to upload CSV files with the information. When
importing files all records are inserted and the duplicates are removed in a
background job for performance reasons.

To keep the plugin simple the uploaded file is processed when the file is
uploaded.
Uploading the file to a temporary storage system and processing it in
background is kept out of the scope for the first release.

### CSV file format

The CSV file format is not configurable. The plugin expects a comma separated
CSV with headers:

```console
ID_NUMBER,BIRTH_DATE
00000000Z,07/03/2014
```

- ID_NUMBER: No format restrictions
- BIRTHDATE: `dd/mm/YYYY` format

The CSV separator can be overriden at installation level by using an
initializer:

```ruby
# config/initializers/file_authorization_handler.rb
Decidim::FileAuthorizationHandler::CsvData.col_sep= ";"
```

### Overriding Authorization Handler name

The authorization handler name is a default one not suitable for end users.
Depending on the use case of the gem needs to be overriden accordingly.

Override the following keys to modify the name of the authorization handler and
its description:

`decidim.authorization_handlers.file_authorization_handler.name`
`decidim.authorization_handlers.file_authorization_handler.description`

You can also override the name of the ID document and birthdate fields:

`activemodel.attributes.file_authorization_handler.id_document`
`activemodel.attributes.file_authorization_handler.birthdate`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-file_authorization_handler'
```

And then execute:

```bash
bundle
bin/rails decidim_file_authorization_handler:install:migrations
bin/rails db:migrate
```

Finally, add the following line to your `config/routes.rb` file:

```ruby
mount Decidim::FileAuthorizationHandler::AdminEngine => '/admin'
```

## Run tests

Create a dummy app in your application (if not present):

```bash
bin/rails decidim:generate_external_test_app
```

And run tests:

```bash
rspec spec
```

## Troubleshooting

If you find the following error after you have installed the engine:

```
undefined method 'decidim_file_authorization_handler_admin_path'
for module#<Module:0x00007fa2aa4e2a10>
```

review if you have mounted the Engine routes into your application routes.

## License

AGPLv3 (same as Decidim)
