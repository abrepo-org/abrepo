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


    return(
        <form id="search-form"
              className="is-flex"
              action={formActionURL}
              acceptCharset="UTF-8"
              method="get">

            <input name="utf8" type="hidden" value="✓" />

            <InputText queryField="query"
                       {...props} />

            <Button disabled={inputBusy} />

            {props.tags &&
             <SearchFilter
                 searchParams={searchParams}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="1"
                 queryField="tags[]"
                 name="Tags"
                 placeholder="Filter Tags"
                 baseURL="/tags.json" />
            }

            {props.industries &&
             <SearchFilter
                 searchParams={searchParams}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="2"
                 queryField="industries[]"
                 name="Industries"
                 placeholder="Filter Industries"
                 baseURL="/industries.json" />
            }
        </form>
    );
};

export default SearchForm;
