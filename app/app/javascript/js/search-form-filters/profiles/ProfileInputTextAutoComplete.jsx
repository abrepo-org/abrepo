import React, { useState, useEffect, useCallback } from 'react';

/*
 * secondary free text search filter input
 */

export const ProfileInputTextAutoComplete = (props) => {

    const changeHandler = (e) => {
        console.log("ChangeHandler", e.target.value);
        props.setInputBusy && props.setInputBusy(true);
        props.setSelectedQuery( [e.target.value] );
    };

    /*
     * hooks n render
     */

    console.log("[ProfileInputTextAutoComplete] Render");

    const selectedQuery = (props.selectedQuery || [])
          .join(" ");

    return(

        <div className="field search-control-field">
          <div id="search-control" className="control has-icons-left">

            <input onChange={(e) => changeHandler(e) }
              autoComplete="off"
              className="input is-small"
              placeholder={props.placeholder}
              type="text"
              id="query"
              value={selectedQuery}
              />

              <span className="icon is-small is-left">
                <i className="fas fa-search"></i>
              </span>
          </div>
        </div>


    );

};

export default { ProfileInputTextAutoComplete };
