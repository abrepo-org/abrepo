import React, { useState, useEffect } from 'react';
import { InputText } from './InputText.jsx';
import { Button } from './Button.jsx';

import { SearchFilter } from './SearchFilter.jsx';

export const SearchForm = (props) => {

    //form state
    const [formActionURL, setFormActionURL]  = useState(props.baseURL);
    const [inputBusy, setInputBusy] = useState(false);
    const [filterOpenState, setFilterOpenState] = useState({
        '1': false,
        '2': false
    });

    //query
    let searchParams = new URLSearchParams(window.location.search);
    //const [query, setQuery] = useState( (searchParams && searchParams.get("query")) || '' );
    let query = searchParams && searchParams.get("query") || '';

    //set tags and industry
    let tags = [];
    let industries = [];

    if (query) {

        //"[tag1], [tag1]"
        tags = query.split(" ")
            .filter(q => q && q.startsWith("[") && q.endsWith("]"))
            .map(q => q.slice(1, -1));

        //"{industry1}, {industry2}.."
        industries = query.split(" ")
            .filter(q => q && q.startsWith("{") && q.endsWith("}"))
            .map(q => q.slice(1, -1));

        //freetext query
        query = query.split(" ")
                     .filter(q => q && !q.startsWith("{") && !q.endsWith("}"))
                     .filter(q => q && !q.startsWith("[") && !q.endsWith("]"));
    }

    const buildFormQuery = (query, selectedTags, selectedIndustries) => {
        console.log("BuildForMQuery", query, selectedTags, selectedIndustries)
        return [
            query,
            selectedTags.map( tag => `[${tag}]`).join(" "),
            selectedIndustries.map( tag => `{${tag}}`).join(" ")
        ].filter(q => q)
         .join(" ")
         .trim()
    }

    const [selectedTags, setSelectedTags] = useState( tags );
    const [selectedIndustries, setSelectedIndustries] = useState( industries );
    const [formQuery, setFormQuery] = useState( buildFormQuery(query, selectedTags, selectedIndustries) );

    console.log("Form tags", selectedTags);
    console.log("Form industries", selectedIndustries);
    console.log("Form query", query);

    useEffect( () => {
        console.log("useEffect")
        setFormQuery(buildFormQuery(query, selectedTags, selectedIndustries));
    });


    console.log("FORM QUERY", formQuery);

    return(
        <form id="search-form"
              className="is-flex"
              action={formActionURL}
              acceptCharset="UTF-8"
              method="get">

            <input key={`input-query`}
                   type="text"
                   name="query"
                   value={formQuery}
                   defaultValue={formQuery} />

            <SearchFilter
                selectedTags={selectedTags}
                setSelectedTags={setSelectedTags}
                filterOpenState={filterOpenState}
                setFilterOpenState={setFilterOpenState}
                id="1"
                queryField="query"
                name="Tags"
                placeholder="CTA, home page"
                baseURL="/tags.json" />


             <SearchFilter
                 selectedTags={selectedIndustries}
                 setSelectedTags={setSelectedIndustries}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="2"
                 queryField="query"
                 name="Industries"
                 placeholder='Internet, Media'
                 baseURL="/industries.json" />


        </form>
    );
};

export default SearchForm;
