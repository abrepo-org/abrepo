import React, { useState, useEffect } from 'react';

export const Button = (props) => {

    return(
        <div className="field">
          <div className="control">
            <input className="ml-4 button is-small is-info"
                   type="submit"
                   disabled={props.disabled}
                   value="Filter" />
          </div>
        </div>
    );
};

export default { Button };
