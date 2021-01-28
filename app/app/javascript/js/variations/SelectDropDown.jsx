import React, { useState, useEffect } from 'react';

const SelectDropDown = (props) => {

    const handleChange = (e) => {
        props.toggleActiveViewHandler( parseInt(e.target.value) );
    };

    return(
        <div className={`select is-small`}>
          <select onChange={handleChange} value={props.activeView}>
            <option value='0'
                    disabled={props.isSingleView}
                    hidden={props.isSingleView}>
              Compare
            </option>
            <option value='1'>Variation</option>
            <option value='2'>Baseline</option>
          </select>
        </div>
    );

};

export default SelectDropDown;
