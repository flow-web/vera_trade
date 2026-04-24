require "test_helper"

module Admin
  class KycControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @document = kyc_documents(:pending_id)
      @document.file.attach(
        io: StringIO.new("fake-pdf-content"),
        filename: "id_card.pdf",
        content_type: "application/pdf"
      )
    end

    # --- Authentication & authorization ---

    test "unauthenticated user is redirected from index" do
      get admin_kyc_index_path
      assert_response :redirect
    end

    test "non-admin user is redirected from index" do
      sign_in users(:one)
      get admin_kyc_index_path
      assert_redirected_to root_path
    end

    test "admin can access index" do
      sign_in @admin
      get admin_kyc_index_path
      assert_response :success
    end

    # --- Show ---

    test "admin can view a document" do
      sign_in @admin
      get admin_kyc_path(@document)
      assert_response :success
    end

    # --- Approve ---

    test "admin can approve a pending document" do
      sign_in @admin
      patch approve_admin_kyc_path(@document)
      assert_redirected_to admin_kyc_index_path

      @document.reload
      assert_equal "approved", @document.status
      assert_equal @admin.id, @document.reviewed_by_id
      assert_not_nil @document.reviewed_at
    end

    # --- Reject ---

    test "admin can reject a document with reason" do
      sign_in @admin
      patch reject_admin_kyc_path(@document), params: { rejection_reason: "Document illisible" }
      assert_redirected_to admin_kyc_index_path

      @document.reload
      assert_equal "rejected", @document.status
      assert_equal "Document illisible", @document.rejection_reason
    end

    test "reject without explicit reason uses default" do
      sign_in @admin
      patch reject_admin_kyc_path(@document)
      assert_redirected_to admin_kyc_index_path

      @document.reload
      assert_equal "rejected", @document.status
      assert_equal "Document non conforme", @document.rejection_reason
    end
  end
end
