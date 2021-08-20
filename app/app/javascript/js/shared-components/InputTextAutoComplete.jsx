import React, { useState, useEffect } from 'react';

export const InputTextAutoComplete = (props) => {

    const baseURL = props.baseURL;
    const destinationSelector = props.destinationSelector;
    const setInputResults = props.setInputResults;
    const placeholder = props.placeholder;
    const updateURL = props.updateURL;
    const queryField = props.queryField || "query"

    let searchParams = new URLSearchParams(window.location.search);
    const [query, setQuery] = useState( (searchParams && searchParams.get(queryField)) || '' );


    const changeHandler = (e) => {

        //TODO: debounce

        props.setInputBusy && props.setInputBusy(true);


        setQuery(e.target.value);

        const response = fetch(`${baseURL}?query=${e.target.value}&partial=true`)
            .then(res => res.text())
            .then(res => {

                /*
                 * pass querySelector if update content is external
                 * of Form / React App
                 * otherwise call setInputResults
                 */

                //update content with available options
                const $destination = document.querySelector(destinationSelector);
                if($destination) {
                    $destination.outerHTML = res;
                }

                //updateValue
                setInputResults && setInputResults(res);

                //updateURL bar w/ change
                updateURL && updateURL(e.target.value);

                props.setInputBusy && props.setInputBusy(false);
            });
    };


    return(
        <div className="field">
            <div id="search-control" className="control has-icons-left">

                <input onChange={(e) => changeHandler(e) }
                       autoComplete="off"
                       className="input is-small"
                       placeholder={placeholder}
                       type="text"
                       name="query" id="query"
                       value={query}
                />

                <span className="icon is-small is-left">
                    <i className="fas fa-search"></i>
                </span>
            </div>
        </div>
    );

};

export default { InputTextAutoComplete };
