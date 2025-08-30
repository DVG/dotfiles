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

RSpec.describe "/brands", type: :request do
  include_context :accounts_and_users
  before { sign_in user }

  shared_examples :authorized_requests do
    describe "HTML POST /brands" do

      describe :successful_requests do
        let(:params) do
          { brand: { name: 'New Brand', account_id: account.id } }
        end

        let(:new_brand) { Brand.last }
        before { post brands_path, params: params }
        it { expect(response).to redirect_to brand_path(new_brand) }
        it { expect(new_brand.name).to eq 'New Brand' }
        it { expect(new_brand.account).to eq account }
      end

    end
  end

  shared_examples :unauthorized_requests do
    describe "HTML POST /brands" do
        let(:params) do
          { brand: { name: 'New Brand', account_id: account.id } }
        end

        let(:new_brand) { Brand.last }
        before { post brands_path, params: params }
        it { expect(response).to redirect_to root_path }
        it { expect(new_brand).to_not be }
    end
  end

  shared_examples :feature_flagged_requests do
    describe "HTML POST /brands" do
      let(:params) do
        { brand: { name: 'New Brand', account_id: account.id } }
      end
      let(:new_brand) { Brand.last }
      before { post brands_path, params: params }
      it { expect(response).to redirect_to home_path }
      it { expect(new_brand).to_not be }
    end
  end

  context "when logged in as an merchant account member in the feature flag cohort" do
    let!(:user) { merchant_user }
    before { Flipper.enable(:alpha, merchant_user) }
    let(:account) { user.current_account }
    it_behaves_like :authorized_requests
  end

  context "when logged in as another merchant account member in the feature flag cohort" do
    let!(:user) { other_merchant_user }
    before { Flipper.enable(:alpha, other_merchant_user) }
    let!(:account) { merchant_account }
    it_behaves_like :unauthorized_requests
  end

  context "when logged in as a merhcant account member not in the feature flag cohort" do
    let!(:user) { merchant_user }
    let(:account) { user.current_account }
    it_behaves_like :feature_flagged_requests
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