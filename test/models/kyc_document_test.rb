require "test_helper"

class KycDocumentTest < ActiveSupport::TestCase
  def attach_fake_file
    { io: StringIO.new("fake-pdf-content"), filename: "doc.pdf", content_type: "application/pdf" }
  end

  test "valid document types" do
    KycDocument::DOCUMENT_TYPES.each do |type|
      doc = KycDocument.new(user: users(:one), document_type: type, status: "pending")
      doc.file.attach(attach_fake_file)
      assert doc.valid?, "#{type} should be valid but got: #{doc.errors.full_messages}"
    end
  end

  test "invalid document type" do
    doc = KycDocument.new(user: users(:one), document_type: "selfie", status: "pending")
    doc.file.attach(attach_fake_file)
    assert_not doc.valid?
  end

  test "file must be attached" do
    doc = KycDocument.new(user: users(:one), document_type: "identity_card", status: "pending")
    assert_not doc.valid?
    assert_includes doc.errors[:file], "doit être joint"
  end

  test "rejection requires a reason" do
    doc = KycDocument.new(user: users(:one), document_type: "identity_card", status: "rejected")
    doc.file.attach(attach_fake_file)
    assert_not doc.valid?
    assert_includes doc.errors[:rejection_reason], "doit être rempli(e)"
  end

  test "approve! sets status and updates user kyc_status" do
    user = users(:one)
    user.update!(kyc_status: "pending")

    id_doc = user.kyc_documents.build(document_type: "identity_card", status: "pending")
    id_doc.file.attach(attach_fake_file)
    id_doc.save!

    addr_doc = user.kyc_documents.build(document_type: "proof_of_address", status: "approved")
    addr_doc.file.attach(attach_fake_file)
    addr_doc.save!

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
    doc = user.kyc_documents.build(document_type: "identity_card", status: "pending")
    doc.file.attach(attach_fake_file)
    doc.save!

    reviewer = users(:two)
    doc.reject!(reviewer, reason: "Photo floue")

    doc.reload
    assert_equal "rejected", doc.status
    assert_equal "Photo floue", doc.rejection_reason
  end
end
