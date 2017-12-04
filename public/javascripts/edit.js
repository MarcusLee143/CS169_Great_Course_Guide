$(function() {
  $(".takenBox").change(function() {
    var split = this.id.split("-");
    $("#" + split[0] + "-choice").prop('checked', true);
  });

  $(".addBox").change(function() {
    var split = this.id.split("-");
    $("#" + split[0] + "-taken").prop('checked', false);
  });

  $('#saveInFilter').click(function() {
    $('#save').click();
  });

  // Get Courses for course search autocomplete
  var all_courses_options = [];
  $.ajax({
    type: "GET",
    url: "/courses/all",
    success: function(response) {
      data = JSON.parse(response);
      for (var i = 0; i < data.length; i++) {
        all_courses_options.push(data[i]["number"] + ": " + data[i]["title"]);      
      }
      set_up_autocomplete("#interested-course-search", all_courses_options);
      set_up_autocomplete("#taken-course-search", all_courses_options);
    }
  });

  function set_up_autocomplete(input_id_string, source) {
    $(input_id_string).autocomplete({ 
        source: source,
        minLength: 2,
        change: function(event, ui) {
          if (!ui.item) {
            $(input_id_string).val('');
            $(input_id_string).focus();
          }
        }
      });
  }

  function validate_input(input_string) {
    if ($.inArray(input_string, all_courses_options) == -1) {
      alert("That isn't a valid class.");
      return false;
    }
    return true;
  }

  $("#add-interested-course").submit(function() {
    let input_string = $('interested-course-search').val();
    return validate_input(input_string);
  });
  $("#add-taken-course").submit(function() {
    console.log("SwS");
    let input_string = $('taken-course-search').val();
    return validate_input(input_string);
  });
  
});

