# MedArrive

This is the official repo for the MedArrive platform.

# Development

## Prerequisites

- [Docker](https://docs.docker.com/docker-for-mac/install/). _Make sure you increase resources allocated to Docker (Preferences -> Resources) to at least 128 GB disk and 8 GB memory._
- Optional: node, npm, yarn - this enables you to run yarn and other JS commands on your host machine instead of inside the docker container, which may be faster

- Because this app uses a private registry for Docker images - Elastic Container Register (ECR) - you will need to get access to AWS CLI
  - Download this [tool](https://github.com/ruimarinho/gsts)
  - Sign in to your Medarrive Google account
  - Determine which group you are in: SSO-Developers | SSO-Administrators | SSO-BI-Developers and replace GROUP with one of those values and run:
  ```
  gsts --aws-role-arn arn:aws:iam::915162735042:role/GROUP --sp-id 1001887944126 --idp-id C02e9eve2 --username YOUR_MEDARRIVE_EMAIL --aws-profile=default --daemon
  ```
  - Please note that if you are on Windows, you cannot run the `--daemon` [option](https://github.com/ruimarinho/gsts#macos-1)
  - Verify it works:
    `aws sts get-caller-identity`
  - If you run into issues, please consult with the `@tech-infra` channel or `@tech-dev`
  ### Note that you will have to re-authenticate to AWS daily

## Installation

- Clone this repo.
- Copy the .env.example file and edit as necessary: `cp -n .env.example .env`.
- Make sure Docker runs without [buildkit](https://docs.docker.com/develop/develop-images/build_enhancements/#to-enable-buildkit-builds)
- Run `make docker.build`
- `make rails.setup_db` to set up the database
- `make rails.seed` to seed the database
- To install node modules, run `make yarn.install`

  - Make sure to re-run this periodically to resolve missing module errors reported from webpacker

- To force rebuild of images, run `make docker.build.force`. This will rebuild the images regardless of if they exist

> For all commands run in the web container, you can use `docker compose run web *` to spin up a new instance, or if you already have one running, `docker compose exec web *` may be faster

### If you encounter an error while building the web container

Try the following steps:

- Ensure that the `version` of `docker compose` is set to `3.4` or higher instead of `3` in `docker compose.yml`.
- Run `make docker.build.force`

## Run the app locally via Docker

- To run a development Rails server: `make docker.up`
  - If you are working on javascripts or other assets related to webpack, you'll want to run webpack-dev-server for a quicker dev cycle. You can use running `docker compose up webpack` in a separate window alongside the Rails server, or run everything at once with `docker compose up`
  - When starting up the webpack-dev-server, wait for the initial compile (it can take about a minute) before any webpack assets are available
  - While this is running, run `make docker.bash` for a bash running against your Docker instance. This is where you should run
    operations like migrations and `rails c`, otherwise you'll run into configuration issues.

### Background Jobs

MedArrive relies on background jobs for processing of long running or computationally complex activities.
To execute those in the background, run `make rails.backgroundjob.start` this will create an executor on your docker instance.

In order to stop these, in case of needing to change logic or to free up cycles, `make rails.backgroundjob.stop`

### Setting up ngrok

If the app is running locally, one can expose the endpoints via [ngrok](https://dashboard.ngrok.com/get-started/setup).

Once ngrok is downloaded and unzipped into the root of this project, running [bin/ngrok](bin/ngrok) will
copy the configuration located at [config/ngrok.yml](config/ngrok.yml) to `~/.ngrok2/ngrok.yml`. This will also attempt
to start ngrok with the tunnel named `med` using

It is designed to run this command on the `med_web` container after running `docker-container up`.

There is also a `make docker.ngrok` that will execute this command for you.

Ngrok provides a free tier. This can be used to expose without specifying tunnel configurations as shown in
[config/ngrok.yml.example](config/ngrok.yml.example).

Once logged into ngrok, `authtoken` can be located on the [Setup Dashboard](https://dashboard.ngrok.com/get-started/setup).

Once an account is created, copy `config/ngrok.yml.example` to `config/ngrok.yml` and specify a tunnel name.
Updating the config with your hostname and Auth Token will start ngrok as expected.

```yaml
---
authtoken: <YourToken>
tunnels:
  med:
    proto: http
    hostname: <medarrive.ngrok.io>
    addr: 0.0.0.0:3000
```

## Super lazy developer tools

[Additional developer tools](./readme/bin.md) can be found in `bin`

## Running tests

- JS tests: `make test.js`
- Ruby tests: `make test.ruby`
- Start guard: `make test.ruby.guard`
- Guard with Rescue: Set ENV of RESCUE_RSPEC to anything for guard to add rescue
  `to_rescue = ENV.key?("RESCUE_RSPEC") ? "rescue" : ""`
  - `make test.rescue` can also be used for this

### Running JS tests in watch mode

To run tests as you make changes to .tsx scripts, run: `make test.js.watch` if you are only working on the UI (React + Storybook).

- If you are rapidly re-running tests, you will want keep a container running to avoid the lost time of re-creating a container with each execution.
  - If you do so, use `docker compose exec <COMMAND>` instead of `docker compose run <COMMAND>`

### Run specs with Guard

If you are running `make docker.up`, then the `guard` service is also running. As such, any change in a spec file or a file with a spec already created, then that spec will run automatically and output printed on your terminal. Note that changes in either `spec_helper` or `rails_helper` will trigger a re-run of all specs.

To run specs without ` make docker.up`, then use: `make test.ruby.guard`. To stop `guard`, press `Ctrl + C`.

### Debugging Rspec tests

Use of Rspec makes testing less painful. Inclusion of aditional tools makes debugging
rspec failures less painful.

- Ruby tests with debug: `make test.rescue`

Use of the `rescue` enables `pry` and its included `pry-stack_explorer`.

These tools provide extended functionality for our existing use of `pry`.

[Pry Stack Explorer for additional context](https://github.com/pry/pry-stack_explorer)

[Pry Rescue for Rspec](https://github.com/conradirwin/pry-rescue)

### Show Coverage Results

SimpleCov has been added to make coverage reporting easy. SimpleCov is run as
part of Rspec and requires no additional operations to work.

Reports of SimpleCov are located in [coverage](coveage/index.html) files after
Rspec has run.

You can open the report by running `make test.coverage`. This will open the report in your default browser.

## Generating model diagram

- Generate PDF file: `make rails.erd`
- Create PDF: `dot -v -Tpdf erd.dot -o erd.pdf`

If dot command fails, install graphviz: [instructions](https://voormedia.github.io/rails-erd/install.html).

## Updating Routes

After adding a new route, run: `make rails.routes` to annotate it and update TypeScript path helpers.

## Running GitHub Actions Locally

_Warning_ GitHooks use the development docker container to execute checks. There can be a long load time the first
time you attempt to commit code if your docker container is not up to date and the system has to wait to build.

It is recommended that you have run `make docker.up` prior to committing code.

### MedArrive has githooks using [FiveStar Git Hooks](https://github.com/fivestars/git-hooks).

An automated script is provided to [install](./bin/direnv/setup_githooks) for your development environment.

Execute `bin/direnv/setup_githooks` to get the hooks wired up locally. This includes all tools needed.

The intent is that all githooks run via "Act" or via `make <command>` using docker. This prevents the need of
having many tools installed on your development machine.

To speed the process,
execute `git config "hooks.pre-commit.parallel" <CPUS>` where CPUS == the number of cores you have given docker.
Default for this is currently 4

Github actions provide a level of security and analysis that helps to prevent future issues.

HadoLint and GitLeaks are executed on push, and pull request actions.

Hooks can be viewed by running `git hooks list`. This shows all executing hooks and the step they are executed on.
We have 7 `make` tasks and 1 `act` action as part of our hooks.

```
pre-commit─┐
           ├─annotate.sh
           ├─js-lint.sh
           ├─rubocop.sh
           ├─shell-check.sh
           ├─yarn-audit.sh
           ├─yarn-integrity.sh
           └─yarn-outdated.sh
```

**Annotate**: Runs rake task via make to keep the annotations on models and routes up to date

**Rubocop**: Runs make task to lint using RuboCop. This only executes vs modified files.

**Shell Check**: Runs `act -j shellcheck` on modified executable shell files to verify they follow best practices

**Yarn Audit**: Runs make task and checks for known security issues with the installed packages.

**Yarn Integrity**: Runs make task to verify that versions and hashed values of the package contents in the project's package. json match those in yarn's lock file.

**Yarn Outdated**: Runs make task that lists version information for all package dependencies. This information includes the currently installed version, the desired version based on semver, and the latest available version.

## Testing actions locally

GitHub actions run in containers much like the rest of the system. To test them locally,
[act](https://github.com/nektos/act) can be installed via `brew install act`. There
are other ways to install but the documentation is well done. [setup_githooks](bin/direnv/setup_githooks) also installs
act for use.

### VCR For Requests

MedArrive uses [VCR](https://github.com/vcr/vcr) for recording requests.
VCR provides the ability to record and replay requests. Use of VCR provides known responses
to queries and external connections.

To record new calls use `RAILS_ENV=test VCR_MODE=rec bundle exec rspec`

This will capture new calls and store them in [cassettes](spec/cassettes).

### List Local Actions

To see what GitHub actions are available, execute `act -l`

```shell
ID           Stage  Name
hadolint     0      hadolint
hadolint-ci  0      hadolint-ci
```

### Running Local Action

Execution of local actions requires docker.

To execute an action `act -j <name>` where name is from the `act -l`

### Test Coverage

SimpleCov has been added to make coverage reporting easy. SimpleCov is run as
part of Rspec and requires no additional operations to work.

Reports of SimpleCov are located in [coverage](coveage/index.html) files after
Rspec has run.

For an accurate representation of code coverage, run all rspec tests.

## Database optimization tools

MedArrive uses [Bullet](https://github.com/flyerhzm/bullet).

This tool allows for capture of N+1 queries and other optimization calls. This tool
is exposed in the Javascript console, Rails Logger, and Javascript actions.

Review the documentation for further details.

## Adding new ENV variables

To add a new ENV variable, you have to perform several steps:

- Add to .env.example and let #dev channel know so people can update their .env
- Add fake key to `config/environments/test.rb`
- Log into AWS and add to `stage-core` and `prod-core` in Secrets Manager.
  - If you don't have permissions for `prod-core`, ask eng leadership.

If your key is used in any initializers, you must additionally:

- Add to Dockerfile and Dockerfile.ci
- Add to `medarrive-infra/blob/main/stacks/aws/med-ci/core/ci-master-pipeline/templates/buildspec.yml`
- Ask Lewis to deploy terraform.

## Front end setup

### Stack

- React
- Webpack (with webpacker, webpacker-react gems)
- TypeScript
- [Elastic UI](https://elastic.github.io/eui/#/)
- Jest and [React Testing Library](https://testing-library.com/docs/) for tests

Other notable front end libraries to take advantage of:

- [react-hook-form](https://react-hook-form.com/) (form management)
- [yup](https://github.com/jquense/yup) (form validation)
- [lodash](https://lodash.com/docs/) (utility functions)
- [moment](https://momentjs.com/) (date/time manipulation; dependency of elastic-ui datepicker)

### How pages are rendered

We don't have a typical SPA. All links and form submissions are synchronous, making a round trip to the Rails back end and rendering a new view.

Each route is handled synchronously by the Rails router and routed to a typical Rails controller action. The action pulls together the data needed for the page, as usual. But instead of rendering a typical ERB file, the action specifies a React component to render. All data needed by that page is packed into a single hash, which is serialized to JSON and ends up being passed to the page component as its props.

In an MVC framework, think of Rails as handling the Models and Controllers, and React handles the Views.

A (simplified) Users#index action would look as follows:

```rb
class UsersController
  def index
    @users = User.all

    # A helper specifies which page component to render.
    # A single `users` prop is passed to the component.
    # We can use @users.as_json(...) with options, or compile our
    # own hash to customize which fields are included.
    render_component "UserIndexPage", users: @users.as_json(only: [:id, :email])
  end
end
```

The corresponding React page component can be rendered as follows:

```ts
type User = { id: number; email: string };
type Props = { users: User[] };

const UserIndexPage: React.FC<Props> = ({ users }) => {
  return (
    <div>
      <h1>Showing {users.count} users</h1>
      <ul>
        {users.map((user) => (
          <li key={user.id}>{user.email}</li>
        ))}
      </ul>
    </div>
  );
};
```

There are different "sections" of the app, including `admin`. Each section has the following pieces (using the admin section for examples):

- A pack file, i.e. `app/javascript/packs/admin.ts`. Each pack file is separately compiled into its own JS source file by Webpack.
  - This is where page components are recognized by WebpackerReact. In order to render a page component from a Rails controller, it must be included and registered here.
- An ERB layout file, i.e. `app/views/layouts/admin.html.erb`. This includes its corresponding pack file and anything else needed for that section.
- Typically, a React layout component that wraps each page body, i.e. `AdminLayout`.
  - Props used by the layout component are contained in the Rails `layout_props` method. `ApplicationController` contains common layout props for all sections, which is overwritten by `Admin::BaseController` which adds to it, and any controller can add additional props to it as needed.
  - Each page using a layout should expect to receive `layout_props` prop and pass it into its surrounding layout component, i.e. `<AdminLayout {...layout_props}>`

### Forms

We use react-hook-form to manage forms. yup may also be used for validations and transforms, and you can use the `yupResolver` to automatically cast and validate form values.

Forms are typically submitted synchronously to the back end, as opposed to an asynchronous request. There is a `useSyncForm()` hook that will return props for the `<SyncForm />` component that's used to wrap form fields and a submit button. It also returns a `submit()` function that can alternatively be used to submit any payload to the configured endpoint.

Our custom field components like `<MedTextField />` expect a FormProvider to be present, already provided by `SyncForm`. You only need to pass a `name` prop to these to register them with the form.

Example: Patient edit form. SyncForm handles the synchronous form submit to the URL and method provided. The field components inside use `useFormContext()` to register with the existing form, since SyncForm wraps fields in a `<FormProvider />` component for us, so we don't need to register them here.

```ts
// Example: using the hook and SyncForm component to create a patient edit form

const PatientEditForm: React.FC<{ patient: Patient }> = ({ patient }) => {
  const { syncFormProps, loading } = useSyncForm({
    url: admin_patient_path(patient.id),
    method: 'put',
    formOptions: {
      defaultValues: { patient },
    },
  });

  return (
    <SyncForm {...syncFormProps}>
      <MedTextField name="patient.first_name" label="First name" />
      <MedTextField name="patient.last_name" label="Last name" />
      <EuiButton type="submit" isLoading={loading}>
        Submit
      </EuiButton>
    </SyncForm>
  );
};
```

### Submitting synchronous data

We may want to make a synchronous non-GET request to the back end without a form, or we may need to handle submit manually in some cases. For this, use the `submit(body)` function returned by the hook to manually make a request.

You can also directly use the `submitSyncForm()` method, passing in the url and method, but you'll have to handle any loading state manually.

```ts
// Example: using the hook to create a new patient

const { submit, loading } = useSyncForm({
  url: admin_patients_path(),
  method: 'post',
});

const manuallyCreatePatient = (first_name, last_name) => {
  submit({ patient: { first_name, last_name } });
};
```

```ts
// Example: using submitSyncForm directly to logout function

const logout = () => submitSyncForm(destroy_user_session_path(), 'delete');
```

### Storybook

We have a Storybook that has a couple of main purposes. First, it will serve as developer documentation for our custom components that can be shared among different pages. Second, it can be used as a sandbox environment to construct static pages. This can be useful when needing to transfer a designer mockup to code, but the back end data is not ready yet.

It doesn't need the Rails server, or Docker at all, to run, as long as you have run `yarn install` locally. Just run `yarn storybook` in your terminal to use it.

## Sticky Filters

Filters are being saved in current user's session. Any controller can activate them on demand by overriding the following method:

```
def enable_session_filters?
  true # this will enable saving filters in the current controller
end
```

After enabling filters you need to set a filters array for that controller, for example if you need to save status and demand partner filters, you can do so by overriding filters method:

```
def filters
  [:status, :demand_partner]
end
```

When doing so the filters for your action will save status and demand_partner filters in session.

### Considerations

- When enabling filters any controller action's have access to `@filters` variable. e.g: `@filters[:status]`.
- Manually resetting filters: When setting `params[:reset_filters]` will reset any saved filters for that route only.
- All filters reset when a user logs out (not sure if this mechanism also applies to a timed out session).

### Not saving in session

The following filters will NOT be saved in session:

- search queries
- pagination
