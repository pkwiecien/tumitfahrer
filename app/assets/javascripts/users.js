//    $("p") get <p> element
//    $("div.intro") get all <p> elements which class="intro"
//    $("p#demo") get all <p> elements which id="demo"
$(document).ready(function () {
    $("#new_user").validate({
        debug: false,
        focusInvalid: true,
        errorClass: "error",
        validClass:"valid",
        highlight: function(element, errorClass) {
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
            //    error.insertBefore("#user_department");
            //} else {
            error.insertBefore(element);
            ///error.appendTo( element.parent() );
            //}
        },
        messages: {
            "user[first_name]": "Please specify your first name",
            "user[last_name]": "Please specify your last name",
            "user[department]": "Please specify your department",
            "user[password]": {
                required: "Please type your password",
                minlength: jQuery.format("At least {0} characters required!")
            },
            "user[email]": {
                required: "We need your email address to contact you",
                email: "Your email address must be in the format of TumID@tum.de"
            }
        }
    });
});