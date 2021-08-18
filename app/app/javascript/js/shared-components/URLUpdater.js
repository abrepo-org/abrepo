export const updateURL = (value) => {

    if (window.history.pushState) {
        let searchParams = new URLSearchParams(window.location.search);
        searchParams.set('query', value);

        const newURL = [
            window.location.origin,
            window.location.pathname,
            '?',
            searchParams.toString()
        ].join("");

        window.history.pushState({path: newURL}, '', newURL);
    }

};


export default { updateURL };
