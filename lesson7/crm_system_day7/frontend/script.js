document.addEventListener('DOMContentLoaded', () => {
    const contactForm = document.getElementById('contactForm');
    const nameInput = document.getElementById('name');
    const emailInput = document.getElementById('email');
    const phoneInput = document.getElementById('phone');
    const submitBtn = document.getElementById('submitBtn');
    const statusMessage = document.getElementById('statusMessage');
    const contactsListDiv = document.getElementById('contactsList');

    const nameError = document.getElementById('nameError');
    const emailError = document.getElementById('emailError');
    const phoneError = document.getElementById('phoneError'); // Unused but good to have

    const BACKEND_URL = 'http://localhost:3000';

    // Function to clear all error messages
    const clearErrors = () => {
        nameError.textContent = '';
        emailError.textContent = '';
        phoneError.textContent = '';
        statusMessage.textContent = '';
        statusMessage.className = 'status-message';
    };

    // Simple email check: has @ with something before and a dot after
    const isValidEmail = (str) => {
        if (typeof str !== 'string') return false;
        const s = str.trim();
        if (!s) return false;
        const at = s.indexOf('@');
        return at > 0 && at < s.length - 1 && s.includes('.', at + 1) && s.lastIndexOf('.') > at;
    };

    const validateForm = (name, email) => {
        clearErrors();
        let isValid = true;

        if (!name.trim()) {
            nameError.textContent = 'Name is required.';
            isValid = false;
        }
        if (!email.trim()) {
            emailError.textContent = 'Email is required.';
            isValid = false;
        } else if (!isValidEmail(email)) {
            emailError.textContent = 'Invalid email format.';
            isValid = false;
        }
        // Add more validation for phone if needed

        return isValid;
    };

    // Function to fetch and display contacts
    const fetchContacts = async () => {
        contactsListDiv.innerHTML = '<p>Loading contacts...</p>';
        try {
            const response = await fetch(`${BACKEND_URL}/api/contacts`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const result = await response.json();
            if (result.data && result.data.length > 0) {
                contactsListDiv.innerHTML = '<ul>' +
                    result.data.map(contact => `<li><strong>${contact.name}</strong> (${contact.email}) - ${contact.phone || 'N/A'}</li>`).join('') +
                    '</ul>';
            } else {
                contactsListDiv.innerHTML = '<p>No contacts yet. Add one above!</p>';
            }
        } catch (error) {
            console.error('Failed to fetch contacts:', error);
            contactsListDiv.innerHTML = '<p class="error">Failed to load contacts. Please check the backend server.</p>';
        }
    };

    // Initial fetch of contacts
    fetchContacts();

    contactForm.addEventListener('submit', async (event) => {
        event.preventDefault(); // Prevent default form submission

        clearErrors(); // Clear previous messages

        const name = nameInput.value;
        const email = emailInput.value;
        const phone = phoneInput.value;

        if (!validateForm(name, email)) {
            statusMessage.textContent = 'Please correct the errors above.';
            statusMessage.classList.add('error');
            return;
        }

        submitBtn.disabled = true;
        submitBtn.textContent = 'Submitting...';
        statusMessage.textContent = 'Sending data...';
        statusMessage.classList.remove('error', 'success');

        try {
            // Ensure we always send valid JSON with string values (no undefined)
            const payload = {
                name: (name || '').trim(),
                email: (email || '').trim(),
                phone: (phone || '').trim()
            };
            const response = await fetch(`${BACKEND_URL}/api/contacts`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(payload),
            });

            let data;
            try {
                data = await response.json();
            } catch (e) {
                data = { message: response.status === 400 ? 'Bad Request - invalid or missing data.' : 'Server error.' };
            }

            if (response.ok) { // Status codes 200-299
                statusMessage.textContent = 'Contact added successfully!';
                statusMessage.classList.add('success');
                contactForm.reset(); // Clear form on success
                fetchContacts(); // Refresh the list of contacts
            } else {
                // Handle server-side validation errors or other API errors
                let errorMessage = 'An unknown error occurred.';
                if (data && data.message) {
                    errorMessage = data.message;
                } else if (response.status === 400) {
                    errorMessage = `Bad Request: ${data.errors ? data.errors.map(e => e.msg).join(', ') : 'Invalid input'}`;
                } else if (response.status === 409) { // Conflict for unique email
                    emailError.textContent = data.message;
                    errorMessage = data.message;
                }
                statusMessage.textContent = `Error: ${errorMessage}`;
                statusMessage.classList.add('error');
            }
        } catch (error) {
            console.error('Network or API call error:', error);
            statusMessage.textContent = 'Network error. Please try again.';
            statusMessage.classList.add('error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Add Contact';
        }
    });
});
