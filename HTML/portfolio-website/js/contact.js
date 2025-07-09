// Contact form functionality
document.addEventListener('DOMContentLoaded', function() {
    const contactForm = document.getElementById('contactForm');
    const submitBtn = document.getElementById('submitBtn');
    const formStatus = document.getElementById('formStatus');
    const messageTextarea = document.getElementById('message');
    const charCount = document.getElementById('charCount');

    // Character counter for message textarea
    messageTextarea.addEventListener('input', function() {
        const currentLength = this.value.length;
        charCount.textContent = currentLength;
        
        if (currentLength > 1000) {
            charCount.style.color = '#e74c3c';
        } else {
            charCount.style.color = '#7f8c8d';
        }
    });

    // Form validation
    function validateForm() {
        let isValid = true;
        const formData = new FormData(contactForm);
        
        // Clear previous errors
        document.querySelectorAll('.error-message').forEach(error => {
            error.textContent = '';
        });
        document.querySelectorAll('.form-group').forEach(group => {
            group.classList.remove('error');
        });

        // Validate name
        const name = formData.get('name').trim();
        if (!name) {
            showError('nameError', 'Name is required');
            isValid = false;
        } else if (name.length < 2) {
            showError('nameError', 'Name must be at least 2 characters');
            isValid = false;
        }

        // Validate email
        const email = formData.get('email').trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!email) {
            showError('emailError', 'Email is required');
            isValid = false;
        } else if (!emailRegex.test(email)) {
            showError('emailError', 'Please enter a valid email address');
            isValid = false;
        }

        // Validate subject
        const subject = formData.get('subject').trim();
        if (!subject) {
            showError('subjectError', 'Subject is required');
            isValid = false;
        } else if (subject.length < 3) {
            showError('subjectError', 'Subject must be at least 3 characters');
            isValid = false;
        }

        // Validate message
        const message = formData.get('message').trim();
        if (!message) {
            showError('messageError', 'Message is required');
            isValid = false;
        } else if (message.length < 10) {
            showError('messageError', 'Message must be at least 10 characters');
            isValid = false;
        } else if (message.length > 1000) {
            showError('messageError', 'Message must be less than 1000 characters');
            isValid = false;
        }

        return isValid;
    }

    function showError(errorId, message) {
        const errorElement = document.getElementById(errorId);
        const formGroup = errorElement.closest('.form-group');
        
        errorElement.textContent = message;
        formGroup.classList.add('error');
    }

    // Form submission
    contactForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        if (!validateForm()) {
            return;
        }

        // Show loading state
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
        formStatus.style.display = 'none';

        try {
            // Simulate form submission (replace with actual endpoint)
            await simulateFormSubmission();
            
            // Show success message
            showFormStatus('success', 'Thank you for your message! I\'ll get back to you within 24 hours.');
            contactForm.reset();
            charCount.textContent = '0';
            
        } catch (error) {
            // Show error message
            showFormStatus('error', 'Sorry, there was an error sending your message. Please try again or contact me directly at bertdezeeuw@live.nl');
        } finally {
            // Reset button state
            submitBtn.classList.remove('loading');
            submitBtn.disabled = false;
        }
    });

    function showFormStatus(type, message) {
        formStatus.className = `form-status ${type}`;
        formStatus.textContent = message;
        formStatus.style.display = 'block';
        
        // Scroll to status message
        formStatus.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    // Simulate form submission (replace with actual form handler)
    async function simulateFormSubmission() {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                // Simulate success (90% chance) or failure (10% chance)
                if (Math.random() > 0.1) {
                    resolve();
                } else {
                    reject(new Error('Simulation error'));
                }
            }, 2000);
        });
    }

    // Real-time validation on blur
    const inputs = contactForm.querySelectorAll('input[required], textarea[required]');
    inputs.forEach(input => {
        input.addEventListener('blur', function() {
            if (this.value.trim()) {
                validateForm();
            }
        });
    });
});