import React, { useState, useEffect } from 'react';
import { InputText } from './InputText.jsx';
import { Button } from './Button.jsx';

import { SearchFilter } from './SearchFilter.jsx';

export const SearchForm = (props) => {

    const [formActionURL, setFormActionURL]  = useState(props.baseURL);
    const [inputBusy, setInputBusy] = useState(false);
    const [filterOpenState, setFilterOpenState] = useState({
        '1': false,
        '2': false
    });

    let searchParams = new URLSearchParams(window.location.search);

    //query
    const [query, setQuery] = useState( (searchParams && searchParams.get("query")) || '' );

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
    }

    //working here - build 'base' query for tags, exlcude industrries, for industries exclude
    //tags, and these get populated in input
    return(
        <form id="search-form"
              className="is-flex"
              action={formActionURL}
              acceptCharset="UTF-8"
              method="get">

            {props.tags &&
             <SearchFilter
                 selectedTags={tags}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="1"
                 queryField="query"
                 name="Tags"
                 placeholder="CTA, home page"
                 baseURL="/tags.json" />
            }

            {props.industries &&
             <SearchFilter
                 selectedTags={industries}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="2"
                 queryField="query"
                 name="Industries"
                 placeholder='Internet, Media'
                 baseURL="/industries.json" />
            }

        </form>
    );
};

export default SearchForm;
