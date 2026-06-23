# AI Agent Instructions for pif

## Project overview
- Ruby web application built with `Sinatra`, `ActiveRecord`, and `Sinatra::Reloader` in development.
- Entry point: `app.rb`; Rack entry: `config.ru`.
- Models are stored in `app/models/`; controllers are in `controllers/`; views are in `views/`; static assets are in `public/`.
- Database config is defined in `config/database.yml`, and `app.rb` currently sets a local PostgreSQL connection for development.
- Authentication uses `OmniAuth` with Google and Twitter providers.

## When editing or generating code
- Preserve existing comments as much as possible.
- Do not remove comments unless they are clearly wrong or misleading.
- If comments are missing or code clarity would improve, add concise comments in Japanese or English consistent with the surrounding file.
- Keep new comments aligned with the existing style in the repository.

## Conventions and patterns
- `app.rb` is the main Sinatra application and loads models/controllers manually.
- Routes are defined directly in `app.rb`; more complex controllers use separate files under `controllers/`.
- Views are ERB templates in `views/` and may rely on helper methods defined in `app.rb`.
- Model classes are defined in `app/models/` with ActiveRecord.
- JavaScript is placed in `public/js/` and CSS in `public/css/`.

## Useful notes for agents
- This repository has minimal documentation beyond `README.md`, so rely on file structure and code conventions.
- There are no automated tests detected; verify behavior by reasoning from code and by preserving existing logic.
- When modifying routes or database-related code, prefer small, incremental changes and preserve current behavior unless a bug fix is explicitly requested.

## Recommended workflows
- For feature or bug work, start by reading `app.rb`, relevant controller(s), and the matching view template.
- When updating UI behavior, inspect `public/js/` and `public/css/` for related logic and styles.
- When working with authentication or session logic, check both `app.rb` helper methods and route guard logic.

## Preferred files for review
- `app.rb`
- `controllers/*.rb`
- `app/models/*.rb`
- `views/*.erb`
- `public/js/*.js`
- `config/database.yml`
- `Gemfile`
