# Context

Read all spec files created or modified in the current branch

# Your Task

Refactor the spec using the following rules:

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