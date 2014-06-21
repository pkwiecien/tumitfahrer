<<<<<<< HEAD



$(document).ready(function () {

//jQuery("departure_place").geocomplete();  // Option 1: Call on element.
//jQuery.fn.geocomplete("input"); // Option 2: Pass element as argument.



  jQuery('#departure_time').datetimepicker();
     $("#ride").validate({
        debug: false,
        focusInvalid: true,
        errorClass: "error",
        validClass:"valid",
        highlight: function(element, errorClass) {
alert("hi beauty");
            $(".error").hidden="false";
            $(element).fadeOut(function() {
                $(element).fadeIn();
            });
        },
        rules: {
            "user[first_name]": {required: true, minlength: 1},
            "user[last_name]": {required: true, minlength: 1 },
            "user[department]": {required: true, minlength: 1 },
            "user[email]": {required: true, email: true},
            //"user[email]": {required: true, email: true, remote:"/users/check_email"},
            "user[password]": {required: true, minlength: 6},
            "user[password_confirmation]": {required: true, equalTo: "#user_password"}
        },
        errorPlacement: function(error, element) {
            //if (element.attr("name") == "user[department]" || element.attr("name") == "user[first_name]" ) {
            // error.insertBefore("#user_department");
            //} else {
            error.insertBefore(element);
            //error.appendTo( element.parent() );
            //}
        },
        messages: {
            "user[first_name]": "Please specify your first name",
            "user[last_name]": "Please specify your last name",
            "user[department]": "Please specify your department",
            "user[password]": {
                required: "Please type your password",
                //minlength: jQuery.format("At least {0} characters required!")
            },
            "user[email]": {
                required: "We need your email address to contact you",
                email: "Your email address must be in the format of TumID@tum.de"
            }
        }
    });
});
=======
//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/
//$ ->
//  $(document).on 'click', 'tr[data-link]', (evt) ->
//    window.location = this.dataset.link
>>>>>>> b2b59b3f985142e3b9fb11ed48780811a44bffbc
