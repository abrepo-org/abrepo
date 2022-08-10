import React, { useState, useEffect } from 'react';
/*
 * DEPRECATED
 */
export const InputText = (props) => {

    const baseURL = props.baseURL;
    const placeholder = props.placeholder;
    const updateURL = props.updateURL;
    const queryField = props.queryField || "query";

    let searchParams = new URLSearchParams(window.location.search);
    const [query, setQuery] = useState( (searchParams && searchParams.get(queryField)) || '' );


    const changeHandler = (e) => {
        setQuery(e.target.value);
    };


    return(
        <div className="field">
            <div id="search-control" className="control has-icons-left">
                <input onChange={(e) => changeHandler(e) }
                       autoComplete="off"
                       className="input is-small"
                       placeholder={placeholder}
                       type="text"
                       name={query ? queryField : ""}
                       id="query"
                       value={query}
                />

                <span className="icon is-small is-left">
                    <i className="fas fa-search"></i>
                </span>
            </div>
        </div>
    );

};

export default { InputText };
