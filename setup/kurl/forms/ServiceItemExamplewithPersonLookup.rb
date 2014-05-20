require File.join(File.dirname(__FILE__),"../config.rb")

service_item "Service Item Example with Person Lookup" do
  catalog CATALOG_NAME
  categories "Example Templates, Example Templates :: Example Templates Subcategory"
  type "Template"
  description "Service Item template with Simple Data Request search for requestor and contact"
  display_page DISPLAY_PAGE
  display_name nil
  web_server WEB_SERVER
  authentication :default
  page "Initial Page",
    :contents,
    :vertical_buttons,
    :submit_button_value => "Submit" do
    section  "Section Example",
      :style_class => " border rounded "
    text "Section Example Title", "Section Example",
      :style_class => " sectionHeader "
    text "Service Item Description", "<p>\nReplace this text with a brief desciption of this service item.\n</p>"
    section  "Submitter",
      :removed
    text "Submitter Header", "Submitter Information",
      :style_class => " primaryColorHeader "
    question "Requester First Name", "Requester First Name", :free_text,
      :required,
      :advance_default,
      :editor_label => "Req First Name",
      :default_form => "KS_SAMPLE_People",
      :default_field => "First Name",
      :default_qual => "'AR Login'=\"$\\USER$\"",
      :size => "20",
      :rows => "1",
      :required_text => "Requester First Name",
      :field_map_number => "1"
    question "Requester Last Name", "Requester Last Name", :free_text,
      :required,
      :advance_default,
      :editor_label => "Req Last Name",
      :default_form => "KS_SAMPLE_People",
      :default_field => "Last Name",
      :default_qual => "'AR Login'=\"$\\USER$\"",
      :size => "20",
      :rows => "1",
      :required_text => "Requester Last Name",
      :field_map_number => "2"
    question "Requester People Number", "Requester People Number", :free_text,
      :advance_default,
      :editor_label => "Req People #",
      :default_form => "KS_SAMPLE_People",
      :default_field => "Request ID",
      :default_qual => "'AR Login'=\"$\\USER$\"",
      :size => "20",
      :rows => "1",
      :field_map_number => "3"
    question "Requester Email Address", "Requester Email", :email,
      :required,
      :advance_default,
      :editor_label => "Req Email Address",
      :default_form => "KS_SAMPLE_People",
      :default_field => "Email",
      :default_qual => "'AR Login'=\"$\\USER$\"",
      :size => "20",
      :required_text => "Requester Email",
      :pattern_label => "Standard Email Address",
      :pattern => "^[\\w-\\.]+\\@[\\w\\.-]+\\.[a-zA-Z]{2,4}$",
      :validation_text => "Requester Email Address (Standard Email Address)",
      :field_map_number => "4"
    question "Req Login ID", "Requester Login ID", :free_text,
      :advance_default,
      :default_form => "KS_SAMPLE_People",
      :default_field => "AR Login",
      :default_qual => "'AR Login'=\"$\\USER$\"",
      :size => "20",
      :rows => "1",
      :field_map_number => "7"
    section  "Requested For Section",
      :style_class => " border rounded "
    text "Requested For Header", "Requested For",
      :style_class => " sectionHeader "
    question "This Request is for", "This Request is for", :list,
      :radio_button,
      :horizontal,
      :required,
      :editor_label => "This Request is For",
      :default_answer => "Myself",
      :choice_list => "This Request is For",
      :field_map_number => "9" do
      choice "Myself", "Myself&nbsp;&nbsp;"
      choice "Another Employee"
      event "Show requested for content",
        :insert_remove,
        :click,
        :fire_if => "obj.value== \"Another Employee\"  && clientManager.submitType != \"ReviewRequest\"" do
        target "Search By Last Name",
          :question,
          :insert
        target "Search Buttons",
          :text,
          :insert
      end
      event "Show Req For Details Section",
        :insert_remove,
        :click,
        :fire_if => "obj.value == \"Another Employee\"" do
        target "Requested For Details Section",
          :section,
          :insert
      end
      event "Clear requested for questions",
        :set_fields_internal,
        :click,
        :fire_if => "obj.value== \"Another Employee\" && clientManager.submitType !=\"ReviewRequest\" && !KD.utils.ClientManager.isLoading" do
        field_map "ReqFor_Login ID", "$\\NULL$"
        field_map "ReqFor_First Name", "$\\NULL$"
        field_map "ReqFor_Last Name", "$\\NULL$"
        field_map "ReqFor_Phone", "$\\NULL$"
        field_map "ReqFor_Email", "$\\NULL$"
        field_map "ReqFor_Org", "$\\NULL$"
        field_map "ReqFor_Dept", "$\\NULL$"
      end
      event "Set requested for default",
        :set_fields_external,
        :click,
        :fire_if => "obj.value == \"Myself\"  && clientManager.submitType !=\"ReviewRequest\" && (clientManager.isNewPage == true || clientManager.isLoading==false)" do
        data_request "KS_SAMPLE_People",
          :sort_fields => "",
          :max_entries => "1",
          :sort_order => "Ascending",
          :qualification => "'AR Login'= $\\USER$"
        field_map "ReqFor_Dept", "<FLD>Department</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Email", "<FLD>Email</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_First Name", "<FLD>First Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Last Name", "<FLD>Last Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Login ID", "<FLD>AR Login</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Org", "<FLD>Region</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Phone", "<FLD>Phone Number</FLD> ",
          :visible_in_table => "Yes"
      end
    end
    question "Search By Last Name", "Last Name", :free_text,
      :removed,
      :transient,
      :size => "40",
      :rows => "1",
      :style_class => " fleft "
    text "Search Buttons", "<div class=\"fleft\" id=\"searchButtons\">\n  <input type=\"button\" value=\"Search\" id=\"b_searchReqFor\" class=\"templateButton\" > \n  <input type=\"button\" value=\"Clear\" id=\"b_clearReqFor\" class=\"templateButton\" > \n  <img id=\"ajax_searchReqFor\" src=\"themes/flyout/common/resources/images/spinner.gif\" alt=\"searching...\" style=\"display:none;\" />\n</div>\n<div class=\"clearfix\"></div>",
      :removed,
      :style_class => " fleft " do
      event "People Search",
        :set_fields_external,
        :click do
        data_request "KS_SAMPLE_People",
          :sort_fields => "Full Name",
          :max_entries => "100",
          :sort_order => "Ascending",
          :qualification => "'Last Name'  LIKE \"<FLD>Search By Last Name;KS05709768505060321d3a786a1873c2270a;ANSWER</FLD>%\""
        field_map "ReqFor_Dept", "<FLD>Department</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Email", "<FLD>Email</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_First Name", "<FLD>First Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Last Name", "<FLD>Last Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Login ID", "<FLD>AR Login</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Org", "<FLD>Region</FLD> ",
          :visible_in_table => "Yes"
        field_map "ReqFor_Phone", "<FLD>Phone Number</FLD> ",
          :visible_in_table => "Yes"
      end
    end
    section  "Requested For Details Section",
      :removed,
      :style_class => " border rounded "
    question "Requested For Login ID", "Requested For Login ID", :free_text,
      :required,
      :editor_label => "ReqFor_Login ID",
      :size => "40",
      :rows => "1",
      :field_map_number => "11"
    question "Requested For First Name", "First Name", :free_text,
      :editor_label => "ReqFor_First Name",
      :size => "40",
      :rows => "1",
      :field_map_number => "12"
    question "Requested For Last Name", "Last Name", :free_text,
      :editor_label => "ReqFor_Last Name",
      :size => "40",
      :rows => "1",
      :field_map_number => "13"
    question "Requested For Email", "Email Address", :free_text,
      :editor_label => "ReqFor_Email",
      :size => "40",
      :rows => "1",
      :field_map_number => "14"
    question "Requested For Phone Number", "Phone Number", :free_text,
      :editor_label => "ReqFor_Phone",
      :size => "40",
      :rows => "1",
      :field_map_number => "15"
    question "ReqFor_Org", "Office", :free_text,
      :size => "40",
      :rows => "1",
      :field_map_number => "28"
    question "ReqFor_Dept", "Branch", :free_text,
      :size => "40",
      :rows => "1",
      :field_map_number => "6"
    section  "Contact Section",
      :style_class => " border rounded "
    text "Contact Header", "Contact Information",
      :style_class => " sectionHeader "
    question "The Contact for this request is", "The Contact for this request is", :list,
      :radio_button,
      :horizontal,
      :required,
      :editor_label => "Contact is",
      :default_answer => "Myself",
      :choice_list => "This Request is For",
      :field_map_number => "16" do
      event "Set contact questions",
        :set_fields_external,
        :click,
        :fire_if => "obj.value == \"Myself\"  && clientManager.submitType !=\"ReviewRequest\" && (clientManager.isNewPage == true || clientManager.isLoading==false)" do
        data_request "KS_SAMPLE_People",
          :sort_fields => "",
          :max_entries => "1",
          :sort_order => "Ascending",
          :qualification => "'AR Login'= $\\USER$"
        field_map "Contact_Email", "<FLD>Email</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_First Name", "<FLD>First Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_Last Name", "<FLD>Last Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_Login ID", "<FLD>AR Login</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_Phone", "<FLD>Phone Number</FLD> ",
          :visible_in_table => "Yes"
      end
      event "Show Contact Details",
        :insert_remove,
        :click,
        :fire_if => "obj.value== \"Another Employee\"" do
        target "Contact Details Section",
          :section,
          :insert
      end
      event "Show contact content",
        :insert_remove,
        :click,
        :fire_if => "obj.value== \"Another Employee\" && clientManager.submitType !=\"ReviewRequest\"" do
        target "Contact Search By Last Name",
          :question,
          :insert
        target "Contact Search Buttons",
          :text,
          :insert
      end
      event "Clear Contact fields",
        :set_fields_internal,
        :click,
        :fire_if => "obj.value== \"Another Employee\" && clientManager.submitType !=\"ReviewRequest\" && !KD.utils.ClientManager.isLoading" do
        field_map "Contact Search By Last Name", "$\\NULL$"
        field_map "Contact_Email", "$\\NULL$"
        field_map "Contact_Phone", "$\\NULL$"
        field_map "Contact_Login ID", "$\\NULL$"
        field_map "Contact_Last Name", "$\\NULL$"
        field_map "Contact_First Name", "$\\NULL$"
      end
    end
    question "Contact Search By Last Name", "Last Name", :free_text,
      :removed,
      :transient,
      :size => "40",
      :rows => "1",
      :style_class => " fleft "
    text "Contact Search Buttons", "<div id=\"searchButtons\" class= \"fleft\">\n  <input type=\"button\" value=\"Search\" id=\"b_searchContact\" class=\"templateButton\" > \n  <input type=\"button\" value=\"Clear\" id=\"b_clearContact\" class=\"templateButton\" > \n<img id=\"ajax_searchContact\" src=\"themes/flyout/common/resources/images/spinner.gif\" alt=\"searching...\" style=\"display:none;\" />\n</div>\n<div class=\"clearfix\"></div>\n\n",
      :removed,
      :style_class => " fleft " do
      event "Contact Lookup",
        :set_fields_external,
        :click do
        data_request "KS_SAMPLE_People",
          :sort_fields => "Full Name",
          :max_entries => "100",
          :sort_order => "Ascending",
          :qualification => "'Last Name' LIKE \"<FLD>Contact Search By Last Name;KSd6badff369814723de6a204ead8a31d947;ANSWER</FLD>%\""
        field_map "Contact_Email", "<FLD>Email</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_First Name", "<FLD>First Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_Last Name", "<FLD>Last Name</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_Login ID", "<FLD>AR Login</FLD> ",
          :visible_in_table => "Yes"
        field_map "Contact_Phone", "<FLD>Phone Number</FLD> ",
          :visible_in_table => "Yes"
      end
    end
    section  "Contact Details Section",
      :removed,
      :style_class => " border rounded "
    question "Contact Login ID", "Contact Login ID", :free_text,
      :required,
      :editor_label => "Contact_Login ID",
      :size => "40",
      :rows => "1",
      :field_map_number => "18"
    question "Contact First Name", "First Name", :free_text,
      :editor_label => "Contact_First Name",
      :size => "40",
      :rows => "1",
      :field_map_number => "19"
    question "Contact Last Name", "Last Name", :free_text,
      :editor_label => "Contact_Last Name",
      :size => "40",
      :rows => "1",
      :field_map_number => "20"
    question "Contact Email", "Email Address", :free_text,
      :editor_label => "Contact_Email",
      :size => "40",
      :rows => "1",
      :field_map_number => "21"
    question "Contact Phone Number", "Phone Number", :free_text,
      :editor_label => "Contact_Phone",
      :size => "40",
      :rows => "1",
      :field_map_number => "22"
    section  "Questions",
      :style_class => " border rounded "
    text "Service Questions", "Please answer the following questions",
      :style_class => " sectionHeader "
    question "Summary", "Summary", :free_text,
      :size => "20",
      :rows => "1",
      :field_map_number => "5"
    question "Notes", "Notes", :free_text,
      :size => "40",
      :rows => "6",
      :field_map_number => "8"
  end
  page "Confirmation Page",
    :confirmation,
    :vertical_buttons,
    :submit_button_value => "Submit",
    :display_page => "/themes/responsive/packages/base/confirmation.jsp" do
    section  "Details"
  end
end
