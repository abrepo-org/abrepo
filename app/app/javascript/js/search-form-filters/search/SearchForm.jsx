import React, { useState, useEffect } from 'react';
import { Button } from '../Button.jsx';
import { buildFormQuery } from '../Util.js';
import { SearchFilter } from './SearchFilter.jsx';



export const SearchForm = (props) => {

    //form state
    const [formActionURL, setFormActionURL]  = useState(props.baseURL);
    const [inputBusy, setInputBusy] = useState(false);
    const [filterOpenState, setFilterOpenState] = useState({
        '1': false,
        '2': false
    });

    //initial url querystring 'query' param
    const searchParams = new URLSearchParams(window.location.search);
    const searchParamsQuery = searchParams && searchParams.get("query") || '';

    //extract and set defaults with array of terms (freetext query, tags, industry)
    const [selectedTags, setSelectedTags] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && q.startsWith("[") && q.endsWith("]"))
            .map(q => q.slice(1, -1));
    })

    const [selectedIndustries, setSelectedIndustries] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && q.startsWith("{") && q.endsWith("}"))
            .map(q => q.slice(1, -1));
    });

    const [selectedQuery, setSelectedQuery] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && !q.startsWith("{") && !q.endsWith("}"))
            .filter(q => q && !q.startsWith("[") && !q.endsWith("]"));
    });

    //query string for form submission
    const [formQuery, setFormQuery] = useState( () => {
        return buildFormQuery(selectedQuery, selectedTags, selectedIndustries);
    });


    /*
     * hooks n render
     */

    useEffect( () => {
        const _formQuery = buildFormQuery(selectedQuery, selectedTags, selectedIndustries);
        setFormQuery(_formQuery);
    });


    return(
        <form id="search-form"
              className="is-flex"
              action={formActionURL}
              acceptCharset="UTF-8"
              method="get">

            <input key={`input-query`}
                   type="text"
                   name="query"
                   hidden={true}
                   readOnly={true}
                   value={formQuery} />

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
