# Context

Read plan.md
RSpec command: `bin/run rspec`
Vitest command: `bin/run vitest`
Lint autocorrect command: `bin/run lint --fix`

# Your Task

Implement the tasks in plan.md following a test driven development methodology. For each change you are considering making, first create a test either in rspec or react testing library. Run the spec and verify it fails first, and then implement the change and verify the test passes. You can optionally take a refactor step after the test is green and verify the test remains green. 

Use the following standards for writing the tests:

*For RSpec:*

* Avoid local variable assigments in favor of `let(:foo)` and `let!(:foo)`
* Favor inline blocks over do...end blocks unless multiple lines are necessary
```
# Do
it { expect(foo).to eq :bar }

# Don't
it "foo equals bar" do
  expect(foo).to eq bar
end
```
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

* For React, unit test components and hooks with react testing library. The test should live alongside the implementation file like so:

```
|- /admin
|---/components
|-----my-component.jsx
|-----my-component.spec.jsx
```
* Use vitest and associated tooling instead of jest (eg. `vi.mock` not `jest.mock`)
