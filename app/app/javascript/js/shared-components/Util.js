
const updateURL = (value) => {

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

const buildFormQuery = (selectedQuery, selectedTags, selectedIndustries) => {

    return [
        selectedQuery,
        selectedTags.map( tag => `[${tag}]`).join(" "),
        selectedIndustries.map( tag => `{${tag}}`).join(" ")
    ].filter(q => q)
        .join(" ")
        .trim();
};


export { updateURL, buildFormQuery };
