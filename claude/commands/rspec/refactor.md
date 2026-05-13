# Context

Read all spec files created or modified in the current branch

# Your Task

Refactor only the lines and blocks that were added or modified in the current branch. Do not refactor unchanged code elsewhere in the file.

Apply the following rules:

## One expect per it

Split `it` blocks with multiple expectations into separate `it` blocks, each with a single expectation.

## Use let instead of local variables

Avoid local variable assignments in favor of `let(:foo)` and `let!(:foo)`.

## Prefer one-line it blocks

Favor inline `it { }` over `it "..." do ... end` unless multiple lines are necessary.

```ruby
# Do
it { expect(foo).to eq :bar }

# Don't
it "foo equals bar" do
  expect(foo).to eq bar
end
```

## Use the implicit subject where possible

When testing the return value of `subject` or `described_class.new`, use `is_expected` instead of explicit `expect(subject)`.

```ruby
# Do
subject { described_class.new(name: 'Widget') }
it { is_expected.to be_valid }
it { is_expected.to be_a Widget }

# Don't
subject { described_class.new(name: 'Widget') }
it { expect(subject).to be_valid }
it { expect(subject).to be_a Widget }
```

## Start context blocks with 'when'

Context descriptions should express variations in state (e.g. `context "when the user is an admin"`).
