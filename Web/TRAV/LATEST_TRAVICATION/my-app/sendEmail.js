const nodemailer = require('nodemailer');

// Create a transporteri using Gmail service
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'olshco.electionupdates@gmail.com', 
        pass: 'nxgb fqoh qkxk svjs', 
    },
});


const sendVerificationEmail = (email, token) => {
    const mailOptions = {
        from: 'olshco.electionupdates@gmail.com', 
        to: email,
        subject: 'Password Reset Verification Token',
        text: `Your password reset token is: ${token}`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            console.error('Error sending email: ', error.message); 
        } else {
            console.log('Email sent: ' + info.response);
        }
    });
};

module.exports = sendVerificationEmail;
