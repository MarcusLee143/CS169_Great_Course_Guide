$(document).ready(function () {

  var all_courses_options = []; 
  var all_courses_data = {};
  var course_professors_data = [];
  var course_professors_options = [];
  var course_professors_options_promise = $.Deferred();

  $.ajax({
    type: "GET",
    url: "/courses/all",
    success: function(response) {
      data = JSON.parse(response);
      for (var i = 0; i < data.length; i++) {
        all_courses_options.push(data[i]["number"] + ": " + data[i]["title"]);
        all_courses_data[data[i]["number"]] = data[i];
      }
      $("#course-search").autocomplete({ 
        source: all_courses_options,
        select: function(event, selected) {
          // Callback function when value is autcompleted.
          $('#professor-search').val("");
          let selected_course_number = selected.item.value.split(": ")[0];
          course_professors_options_promise = $.Deferred();
          professor_options(selected_course_number, function() {
            course_professors_options_promise.resolve();
          });
        },
        minLength: 2, // The minimum length of the input for the autocomplete to start. 
      });
    }
  });

  // Get prof options corresponding to selected course
  function professor_options(selected_course_number, callback) {   
    return $.ajax({
      type: "GET",
      // async: false,
      url: "/professors/all",
      success: function(response) {
        course_professors_data = [];
        course_professors_options = []
        data = JSON.parse(response);
        for (var i = 0; i < data.length; i++) {
          if (selected_course_number == data[i]["number"]) {
            course_professors_options.push(data[i]["professor_name"]);
          } 
          course_professors_data.push(data[i]);
        }
        course_professors_options = [... new Set(course_professors_options)]
        callback();
        $("#professor-search").autocomplete({ 
          source: course_professors_options,
          minLength: 2
        });
      }
    });
  };

  $('#addCourse').click(function() {
    let selected_course_name = $('#course-search').val();
    let selected_professor_name = $('#professor-search').val();

    $('#data-loader').show();

    // Clear previous values
    $('#course-search').val("");
    $('#professor-search').val("");

    if (!validate_inputs(selected_professor_name, selected_course_name)) {
      $('#data-loader').hide();
      return;
    }

    let selected_course_number = selected_course_name.split(": ")[0];
    var selected_course_data = all_courses_data[selected_course_number];

    $.when(course_professors_options_promise).then(function() {
      $('#data-loader').hide();
      if (selected_professor_name == "") {
        for (var i = 0; i < course_professors_options.length; i++) {
          let professor_name = course_professors_options[i];
          var ratings = average_ratings(professor_name, selected_course_number);
          $('#selected-courses').append("<tr><td>" + selected_course_number + "</td><td>" + selected_course_data["units"]
              + "</td><td>" + professor_name + "</td><td>" + ratings[0] + "</td><td>" + ratings[1] 
              + `</td><td><a id="remove_course_item" class="btn-floating btn-small waves-effect waves-light grey"><i class="material-icons">remove_circle_outline</i></a></td></tr>`);

        }
      } else {
        var ratings = average_ratings(selected_professor_name, selected_course_number);
        $('#selected-courses').append("<tr><td>" + selected_course_number + "</td><td>" + selected_course_data["units"]
          + "</td><td>" + selected_professor_name + "</td><td>" + ratings[0] + "</td><td>" + ratings[1] 
          + `</td><td><a id="remove_course_item" class="btn-floating btn-small waves-effect waves-light grey"><i class="material-icons">remove_circle_outline</i></a></td></tr>`);
      }
    });
  });

  // Remove course item button function
  $('table').on('click', '#remove_course_item', function() {
    $(this).closest('tr').remove();
  });

  // Quick add by pressing 'enter' key
  $(document).keypress(function(e) {
    if(e.which == 13) {
        $('#addCourse').click();
    }
  });

  function validate_inputs(selected_professor_name, selected_course_name) {
    if (selected_course_name == "") {
      alert("Please select a class.");
      return false;
    }
    if ($.inArray(selected_course_name, all_courses_options) == -1) {
      alert("That isn't a valid class.");
      return false;
    }
    if (selected_professor_name != "" && $.inArray(selected_professor_name, course_professors_options) == -1) {
      alert("That isn't a valid professor.");
      return false;
    }
    return true;
  };

  function average_ratings(selected_professor_name, selected_course_number) {
    var total_overall_rating = total_overall_count = total_course_rating = total_course_count = 0;
    for (var i = 0; i < course_professors_data.length; i++) {
      let professor_data = course_professors_data[i];
      if (professor_data["professor_name"] === selected_professor_name) {
        total_overall_rating += professor_data["rating"];
        total_overall_count += 1;
        if (professor_data["number"] === selected_course_number) {
          total_course_rating += professor_data["rating"];
          total_course_count += 1;
        }
      }
    }
    return [(total_overall_rating / total_overall_count).toFixed(2), (total_course_rating / total_course_count).toFixed(2)];
  }
});