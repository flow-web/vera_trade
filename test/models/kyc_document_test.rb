require "test_helper"

class KycDocumentTest < ActiveSupport::TestCase
  test "valid document types" do
    KycDocument::DOCUMENT_TYPES.each do |type|
      doc = KycDocument.new(user: users(:one), document_type: type, status: "pending")
      doc.file.attach(io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg")
      assert doc.valid?, "#{type} should be valid but got: #{doc.errors.full_messages}"
    end
  end

  test "invalid document type" do
    doc = KycDocument.new(user: users(:one), document_type: "selfie", status: "pending")
    doc.file.attach(io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg")
    assert_not doc.valid?
  end

  test "file must be attached" do
    doc = KycDocument.new(user: users(:one), document_type: "identity_card", status: "pending")
    assert_not doc.valid?
    assert_includes doc.errors[:file], "doit être joint"
  end

  test "rejection requires a reason" do
    doc = KycDocument.new(user: users(:one), document_type: "identity_card", status: "rejected")
    doc.file.attach(io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg")
    assert_not doc.valid?
    assert_includes doc.errors[:rejection_reason], "doit être rempli(e)"
  end

  test "approve! sets status and updates user kyc_status" do
    user = users(:one)
    user.update!(kyc_status: "pending")

    id_doc = user.kyc_documents.create!(
      document_type: "identity_card",
      status: "pending",
      file: fixture_file_upload("test_image.jpg", "image/jpeg")
    )

    addr_doc = user.kyc_documents.create!(
      document_type: "proof_of_address",
      status: "approved",
      file: fixture_file_upload("test_image.jpg", "image/jpeg")
    )

    reviewer = users(:two)
    id_doc.approve!(reviewer)

    id_doc.reload
    assert_equal "approved", id_doc.status
    assert_equal reviewer.id, id_doc.reviewed_by_id

    user.reload
    assert_equal "verified", user.kyc_status
  end

  test "reject! sets status with reason" do
    user = users(:one)
    doc = user.kyc_documents.create!(
      document_type: "identity_card",
      status: "pending",
      file: fixture_file_upload("test_image.jpg", "image/jpeg")
    )

    reviewer = users(:two)
    doc.reject!(reviewer, reason: "Photo floue")

    doc.reload
    assert_equal "rejected", doc.status
    assert_equal "Photo floue", doc.rejection_reason
  end
end
