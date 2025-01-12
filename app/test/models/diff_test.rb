# == Schema Information
#
# Table name: diffs
#
#  id                     :bigint           not null, primary key
#  calculated             :json
#  crawlId                :string
#  diffPanel              :string           default("true")
#  diffType               :string
#  newDim                 :json
#  origDim                :json
#  selector               :string
#  selectorDisplayName    :string
#  summary_added          :string
#  summary_added_format   :string
#  summary_delta          :string
#  summary_removed        :string
#  summary_removed_format :string
#  viewMode               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  a_id                   :string
#  group_id               :string
#  renderable_id          :bigint
#
# Indexes
#
#  index_diffs_on_renderable_id  (renderable_id)
#
# Foreign Keys
#
#  fk_rails_...  (renderable_id => renderables.id)
#

require 'test_helper'

class DiffTest < ActiveSupport::TestCase
  def setup
    @diff = diffs(:diff_one)
    @diff2 = diffs(:diff_one)
  end

  test "valid diff" do
    assert @diff.valid?
    assert @diff2.valid?
  end

  test "presence of a_id" do
    @diff.a_id = nil
    assert_not @diff.valid?
    assert_includes @diff.errors[:a_id], "can't be blank"
  end

  test "presence of renderable_id" do
    @diff.renderable_id = nil
    assert_not @diff.valid?
    assert_includes @diff.errors[:renderable_id], "can't be blank"
  end

  test "randomizeBoundingBox updates bounding box" do

    xnew = @diff['newDim']['pageDims']['screenshot_dimensions']['width']
    ynew = @diff['newDim']['pageDims']['screenshot_dimensions']['height']

    xorig = @diff['origDim']['pageDims']['screenshot_dimensions']['width']
    yorig = @diff['origDim']['pageDims']['screenshot_dimensions']['height']

    @diff.randomizeBoundingBox

    assert @diff.newDim['boundingBox']['rect'].key?('x')
    assert_not_equal @diff.newDim['boundingBox']['rect']['x'], xnew

    assert @diff.newDim['boundingBox']['rect'].key?('y')
    assert_not_equal @diff.newDim['boundingBox']['rect']['y'], ynew

    assert @diff.origDim['boundingBox']['rect'].key?('x')
    assert_not_equal @diff.origDim['boundingBox']['rect']['x'], xorig

    assert @diff.origDim['boundingBox']['rect'].key?('y')
    assert_not_equal @diff.origDim['boundingBox']['rect']['y'], yorig
  end

  test "removeDetails removes selectors" do
    @diff.selector = "Test Selector"
    @diff.selectorDisplayName = "Test Display Name"
    @diff.calculated = {'some' => 'data'}

    @diff.removeDetails

    assert_empty @diff.calculated
    assert_nil @diff.selector
    assert_nil @diff.selectorDisplayName
  end

  test "isNotVisible returns true when both newDim and origDim are not visible" do
    @diff.newDim['isVisible'] = false
    @diff.origDim['isVisible'] = false

    assert @diff.isNotVisible
  end

  test "isNotVisible returns false when both  when both newDim and origDim are visible" do
    @diff.newDim['isVisible'] = true
    @diff.origDim['isVisible'] = true

    assert_not @diff.isNotVisible
  end

  test "avgY returns Float::INFINITY when not visible" do
    @diff.newDim['isVisible'] = false
    assert_equal Float::INFINITY, @diff.avgY
  end

  test "avgY calculates average of Y values" do
    @diff.newDim['boundingBox']['rect']['y'] = 20
    @diff.origDim['boundingBox']['rect']['y'] = 40
    assert_equal 30, @diff.avgY
  end

  test "avgY returns newY when origY is nil" do
    @diff.newDim['boundingBox']['rect']['y'] = 20
    @diff.origDim['boundingBox']['rect']['y'] = nil
    assert_equal 20, @diff.avgY
  end

  test "avgY returns origY when newY is nil" do
    @diff.newDim['boundingBox']['rect']['y'] = nil
    @diff.origDim['boundingBox']['rect']['y'] = 40
    assert_equal 40, @diff.avgY
  end

  test "format_summaries formats summary_delta correctly" do
    @diff.summary_delta = "some css and cta content"
    @diff.format_summaries
    assert_equal "Some CSS and CTA content", @diff.summary_delta
  end

  test "as_json includes diffType" do
    @diff.diffType = "exampleType"
    json = @diff.as_json
    assert_equal "exampleType", json[:type]
  end

end
