import React, { useState, useEffect } from 'react';

export const SearchForm = (props) => {

    let searchParams = new URLSearchParams(window.location.search);
    const [query, setQuery] = useState( (searchParams && searchParams.get("query")) || '' );
    /*
     *working here: fix reorg form values (e.g values as param) etc
     */


    return(
        <form id="search-form"
              className="is-flex"
              action="/search"
              acceptCharset="UTF-8"
              method="get">
            <input name="utf8" type="hidden" value="✓" />

            <div className="field">
                <div id="search-control" className="control has-icons-left">

                    <input className="input is-small"
                           placeholder="query"
                           type="text" name="query" id="query"
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
                           type="submit" value="Submit" />
                </div>
            </div>


            <div className="field">

                <div className="dropdown is-active">
                    <div className="dropdown-trigger">
                        <button className="button" aria-haspopup="true" aria-controls="dropdown-menu-tag">
                            <span>Tag</span>
                            <span className="icon is-small">
                                <i className="fas fa-angle-down" aria-hidden="true"></i>
                            </span>
                        </button>
                    </div>

                    <div className="dropdown-menu" id="dropdown-menu-tag" role="menu">
                        <div className="dropdown-content">

                            <div className="dropdown-item">
                                <p>You can insert <strong>any type of content</strong> </p>
                            </div>

                            <hr className="dropdown-divider" />
                            <div className="dropdown-item">
                                <p>You simply need to use a <code>&lt;div&gt;</code> instead.</p>
                            </div>

                            <hr className="dropdown-divider" />
                            <a href="#" className="dropdown-item">

                            </a>
                        </div>
                    </div>

                </div>
            </div>
        </form>
    );
};

export default SearchForm;
