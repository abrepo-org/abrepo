document.addEventListener('DOMContentLoaded', () => {

    const $manageAcct = document.querySelector('#manageAccount');

    $manageAcct.addEventListener('click', function(e) {
        e.preventDefault();
        const token = e.target.getAttribute('token');

        fetch('/customer-portal', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': token
            },
            body: JSON.stringify({}),
        }).then((response) => response.json())
          .then((data) => {
              window.location.href = data.url;
          })
          .catch((error) => {
              console.error('Error:', error);
          });

    });
});
