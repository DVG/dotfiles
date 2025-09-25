Please analyze all code in this branch that is diverged from main and get it ready for PR by:

1. Run rspec with `bin/run rspec` and get all tests to green
2. Run vitest with `bin/run vitest` and get all tests to green
3. Running `bin/run lint --fix` to run all linters in autocorrect mode. Anything that cant be autocorrected, correct manually

Any new files should have tests created to test them. New API endpoints should get a request spec. Follow the following conventions:

* For React, unit test components and hooks with react testing library. The test should live alongside the implementation file like so:

```
|- /admin
|---/components
|-----my-component.jsx
|-----my-component.spec.jsx
```
* Use vitest and associated tooling instead of jest (eg. `vi.mock` not `jest.mock`)

* For Rails, write rspec unit tests for all classes, testing all functionality.
* Favor inline blocks over do...end blocks unless multiple lines are necessary
* Start context blocks with 'when' (e.g. when the foo is nil)
* Make several its with one expectation each instead of one it with several expectations
* Use the following template for request specs:

```
require 'rails_helper'

RSpec.describe "/widgets", type: :request do
  include_context :accounts_and_users
  before { sign_in user }

  shared_examples :authorized_requests do
    describe "HTML POST /widgets" do

      describe :successful_requests do
        let(:params) do
          { brand: { name: 'New Widget', account_id: account.id } }
        end

        let(:new_widget) { Widget.last }
        before { post widgets, params: params }
        it { expect(response).to redirect_to widget_path(new_widget) }
        it { expect(new_widget.name).to eq 'New Widget' }
        it { expect(new_widget.account).to eq account }
      end

    end
  end

  shared_examples :unauthorized_requests do
    describe "HTML POST /widgets" do
        let(:params) do
          { widget: { name: 'New Brand', account_id: account.id } }
        end

        let(:new_widget) { Brand.last }
        before { post widgets_path, params: params }
        it { expect(response).to redirect_to root_path }
        it { expect(new_widget).to_not be }
    end
  end

  context "when logged in as an account member" do
    let!(:user) { account_user }
    let(:account) { user.current_account }
    it_behaves_like :authorized_requests
  end

  context "when logged in as another merchant account member" do
    let!(:user) { other_account_user }
    let!(:account) { other_account_user.current_account }
    it_behaves_like :unauthorized_requests
  end
end
```

If you need to update a spec that breaks these conventions, refactor or move the file to make it conventional.
