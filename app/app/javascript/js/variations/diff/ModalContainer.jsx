import React, {useState} from 'react';
import ReactDOM from 'react-dom';
import ModalContent from './ModalContent.jsx';
import DiffView from './DiffView.jsx';

const ModalContainer = (props) => {

    const [diff, setDiff] = useState(props.diff);
    const [classNames, setClassNames] = useState(props.classNames || "");
    const [title, setTitle] = useState(props.title);

    const isOpen = props.diff ? 'is-active' : '';

    console.log("ModalContainer:", props.diff);
    console.log("isOpen", isOpen);


    return(
        <div className={`modal ${classNames} ${isOpen}`}>
          <div className="modal-background"></div>
          <div className="modal-card">

            <header className="modal-card-head">

                <div className="modal-card-title">{title}</div>

              <button onClick={() => props.modalLaunchHandler(null)}
                      className="delete is-large"
                      aria-label="close">
              </button>
            </header>


            <section className="modal-card-body diffPanel">

                {props.diff &&
                 <>
                 <DiffView diff={props.diff} detail={false}/>
                 <hr />
                 <ModalContent diff={props.diff} />
                 </>
                }


            </section>

            <footer className="modal-card-foot">
            </footer>

          </div>
        </div>
    );

};


export default ModalContainer;
