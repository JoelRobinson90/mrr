require "rails_helper"

RSpec.describe Okta::GetUserInfo, :vcr do
  before do
    Timecop.freeze(Time.at(1668530503))

    allow(RestClient).to receive(:post).and_call_original
  end

  after { Timecop.return }

  subject { described_class.call(token) }

  context "valid okta token" do
    let(:token) do
      "eyJraWQiOiJUaEJXcFRhSkJUNUczSWtJZWRNVmF2eWU4eElIMV95M2MtdXBNbjFoX1JBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULk5yUHg4elhjVEVhNnQtQVlsREt4VHJxVno0bkx1TXhQQmpNd1BmUGFfejAub2FyZG9wd3Z5V3ljSzB3ZFU2OTYiLCJpc3MiOiJodHRwczovL21lZGFycml2ZS5va3RhLmNvbSIsImF1ZCI6Imh0dHBzOi8vbWVkYXJyaXZlLm9rdGEuY29tIiwic3ViIjoiZXJpa0BtZWRhcnJpdmUuY29tLnBvYyIsImlhdCI6MTY2ODUzMDQ2OCwiZXhwIjoxNjY4NTM0MDY4LCJjaWQiOiIwb2Eydzl1cDBmTTc0WlhZYTY5NyIsInVpZCI6IjAwdThybDdhcjJZYlJvZWh2Njk2Iiwic2NwIjpbIm9wZW5pZCIsImVtYWlsIiwicHJvZmlsZSIsIm9mZmxpbmVfYWNjZXNzIl0sImF1dGhfdGltZSI6MTY2ODUyNjIxNX0.IRgVhPeVQQLnnSSwtDyiBXmDy81ifze14CJ3qhiHC5yaRl78najJBrgceCAEtBxJaJ8Q9b9sQv2k82gBCFE1iUHNMvXIKFX9DeWHUxQLwwtzIkP8coZ8JR1CTwrcbo8t1Uplr5AS5Cg-HS0VP6kNSFLXHe1RN6M6TFuQvYqf-Rmnqk8eB7YZsXXvLjoVHYwWafiLpNZiHy7mL3jckjyMtzNQnkfBWz6K6oYPtgWIUXelN3DAzEdOzRcfYVwkVyo8rwQNdK0c-V2_0FJjkv6i0rQQYnYMh7BzH82dn21peCGDbw3SEas4J8oTQkJ9rIbQqKqFSlAK1B7iU6SZHLzRSg"
    end

    it "successfully fetches user info" do
      expect(subject).to be_success
      expect(RestClient).to have_received(:post)
      expect(subject.payload).to include("email" => "erik@medarrive.com")
    end
  end

  context "valid token syntax not signed by okta" do
    let(:token) do
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE2Njg1Mzk2MDN9.SYon4U8fv6zpF2B9n0ZR67KUuYcBnyNZit4mbdxIGZg"
    end

    it "makes an api call and invalidates token" do
      expect(subject).not_to be_success
      expect(RestClient).to have_received(:post)
      expect(subject.error).to include("invalid")
    end
  end

  context "expired token" do
    let(:token) do
      "eyJraWQiOiJUaEJXcFRhSkJUNUczSWtJZWRNVmF2eWU4eElIMV95M2MtdXBNbjFoX1JBIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmhwbkZ3bUoxSjFEZml4dlJoalFfcDBfOFhTblJLOWZDN2U2eHd6X1Zxc0Eub2FyZG16OXgxeWZRaFNFSjU2OTYiLCJpc3MiOiJodHRwczovL21lZGFycml2ZS5va3RhLmNvbSIsImF1ZCI6Imh0dHBzOi8vbWVkYXJyaXZlLm9rdGEuY29tIiwic3ViIjoiZXJpa0BtZWRhcnJpdmUuY29tLnBvYyIsImlhdCI6MTY2ODQ1NDc0MiwiZXhwIjoxNjY4NDU4MzQyLCJjaWQiOiIwb2Eydzl1cDBmTTc0WlhZYTY5NyIsInVpZCI6IjAwdThybDdhcjJZYlJvZWh2Njk2Iiwic2NwIjpbIm9wZW5pZCIsImVtYWlsIiwicHJvZmlsZSIsIm9mZmxpbmVfYWNjZXNzIl0sImF1dGhfdGltZSI6MTY2ODQ1NDc0MX0.XWfCGXrFzCsZ4ppI3InZ2iggGl0nj00tVaVdispTu2P-Z7OH7Yv8dleR7brKRMBd0HWCeg0aGSH3EZpjhpkuCqS1oJxcgnq3Nk4tMKvMAo7QCY8Xcu-8zRA2kgBfUEd8HAcNy2gx7YBkgCSJJq5eXbRlQYjytpoPgoMBS7jlOQh3-GNlKaby4aTMVfUGmjumv1R7-S7WSKvMXGwrOpIkv8KdY6GLEiB6nOpn3ueQzMdWQhBeXRHl5_Apts1DoxW5HcrZa4xDEt8zl5td7LLmKprGoTkoQVp-Kkny_yzNiGGndQ-8GM1SiiOy6AZ4IAaxb6S4eEawO9pepgwleqzjow"
    end

    it "invalidates token before making api call" do
      expect(subject).not_to be_success
      expect(RestClient).not_to have_received(:post)
      expect(subject.error).to include("expired")
    end
  end

  context "invalid format" do
    let(:token) do
      "invalid-format-token"
    end

    it "invalidates token before making api call" do
      expect(subject).not_to be_success
      expect(RestClient).not_to have_received(:post)
      expect(subject.error).to include("invalid")
    end
  end
end
