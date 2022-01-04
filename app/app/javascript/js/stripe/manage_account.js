document.addEventListener('DOMContentLoaded', () => {

    const $manageAcct = document.querySelector('#manageAccount');
    const $err = document.querySelector('#manageAccount-err');

    if (!$manageAcct) return;

    $manageAcct.addEventListener('click', function(e) {

        e.preventDefault();

        const token = e.target.getAttribute('token');

        //clear err
        $err.innerHTML = '';

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

              //append error message
              $err.innerHTML = "There was an error loading your account information.";
          });

    });
});
