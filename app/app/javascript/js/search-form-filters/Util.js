const updateURL = (value) => {

    if (window.history.pushState) {
        let searchParams = new URLSearchParams(window.location.search);

        //any autocomplete input - remove pagination from URL
        //results aren't paginatinoed
        searchParams.delete('page');

        searchParams.set('query', value);

        //empty query param values (e.g. deleted input box)
        //remove param entirely cosmetic
        if (!value.trim()) {
            searchParams.delete('query');
        }

        const newURL = [
            window.location.origin,
            window.location.pathname,
            searchParams.toString() ? `?${searchParams.toString()}` : ''
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
