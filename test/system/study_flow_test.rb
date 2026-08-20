require "application_system_test_case"

class StudyFlowTest < ApplicationSystemTestCase
  test "user creates a note with an image and reviews it" do
    visit new_user_registration_path

    find("#user_email").set("system-learner@example.com")
    find("#user_password").set("password123")
    find("#user_password_confirmation").set("password123")

    assert_equal "password123", find("#user_password").value
    assert_equal "password123", find("#user_password_confirmation").value
    click_button "회원가입"

    assert_text "기억하고 싶은 내용을 꾸준히 복습하세요"

    click_link "주제 관리하기"
    click_link "새 주제"
    fill_in "주제 이름", with: "생물학"
    click_button "주제 만들기"

    click_link "생물학"
    click_link "새 메모"
    fill_in "질문", with: "세포의 발전소라고 불리는 소기관은?"
    fill_in "답변", with: "미토콘드리아"
    attach_file "답변 이미지", Rails.root.join("public/icon.png")
    click_button "메모 만들기"

    assert_text "세포의 발전소라고 불리는 소기관은?"
    assert_text "미토콘드리아"
    assert_selector "img[alt='답변 첨부 이미지']", count: 1

    click_link "주제 목록"
    click_link "복습 1개"

    assert_text "세포의 발전소라고 불리는 소기관은?"
    find("summary", text: "답 보기").click
    assert_text "미토콘드리아"
    click_button "좋음"

    assert_text "복습 결과가 저장되었습니다."
    assert_text "지금 복습할 메모가 없습니다."
    assert_text "가장 가까운 다음 복습"

    page.current_window.resize_to(390, 844)

    visit root_path
    assert_no_horizontal_overflow

    click_link "주제 관리하기"
    assert_link "새 주제"
    assert_no_horizontal_overflow

    click_link "생물학"
    assert_link "새 메모"
    assert_no_horizontal_overflow

    visit review_path
    assert_text "오늘의 복습"
    assert_no_horizontal_overflow
  end

  private

  def assert_no_horizontal_overflow
    fits_viewport = page.evaluate_script(<<~JAVASCRIPT)
      document.documentElement.scrollWidth <=
        document.documentElement.clientWidth
    JAVASCRIPT

    assert fits_viewport, "페이지에 모바일 화면보다 넓은 내용이 있습니다."
  end
end
