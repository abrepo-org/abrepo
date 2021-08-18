import React, { useState, useEffect } from 'react';

export const InputAutoCompleteForm = (props) => {

    const baseURL = props.baseURL;
    const destination = props.destination;
    const updateURL = props.updateURL;
    let searchParams = new URLSearchParams(window.location.search);

    const [query, setQuery] = useState( (searchParams && searchParams.get("query")) || '' );
    const [submitDisabled, setSubmitDisabled] = useState(false);

    const changeHandler = (e) => {

        //TODO: debounce

        setSubmitDisabled(true);

        setQuery(e.target.value);

        const response = fetch(`${baseURL}?query=${e.target.value}&partial=true`)
            .then(res => res.text())
            .then(res => {

                const $destination = document.querySelector(destination);

                //update content
                if($destination) {
                    $destination.outerHTML = res;
                }

                //updateURL if available
                if (updateURL) {
                    updateURL(e.target.value);
                }

                setSubmitDisabled(false);
            });
    };


    return(
        <form id="tag-filter"
              className="is-flex"
              action={baseURL}
              acceptCharset="UTF-8"
              method="get">

            <input name="utf8" type="hidden" value="✓" />

            <div className="field">
                <div id="search-control" className="control has-icons-left">

                    <input onChange={(e) => changeHandler(e) }
                           className="input is-small"
                           placeholder="Filter Tags"
                           type="text"
                           name="query" id="query"
                           value={query}
                    />

                    <span className="icon is-small is-left">
                        <i className="fas fa-search"></i>
                    </span>
                </div>
            </div>

            <div className="field">
                <div className="control">
                    <input className="ml-4 button is-small is-info"
                           type="submit"
                           disabled={submitDisabled}
                           value="Submit" />
                </div>
            </div>
        </form>
    );

};

export default { InputAutoCompleteForm };
