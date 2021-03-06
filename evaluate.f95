subroutine evaluate(node, element, P, splits)

    use types
    use parameters
    use linear_algebra

    implicit none

    type(fem_node),       intent(in)  :: node
    type(fem_element),    intent(in)  :: element
    real,                 intent(in)  :: P(size(node%x))
    integer,              intent(out) :: splits(size(element%c))

    real    :: C(2:3, 3), &
               l12, l23, l31, &
               A(size(element%c)), &
               elem_dP(size(element%c), 2), &
               node_dP(size(node%x), 2), &
               estm_dP(size(element%c), 2), &
               err_norm(size(element%c)), &
               mean_err, var_err, stdev_err

    integer :: cnt(size(node%x))


    elem_dP = 0
    cnt = 0
    node_dP = 0
    A = 0

    do n = 1, size(elem_dP, dim = 1)

        ! Generate the 2nd and 3rd row of C matrix
        C(2, 1) = node%y(element%node(n, 2)) - node%y(element%node(n, 3))
        C(2, 2) = node%y(element%node(n, 3)) - node%y(element%node(n, 1))
        C(2, 3) = node%y(element%node(n, 1)) - node%y(element%node(n, 2))
        C(3, 1) = node%x(element%node(n, 3)) - node%x(element%node(n, 2))
        C(3, 2) = node%x(element%node(n, 1)) - node%x(element%node(n, 3))
        C(3, 3) = node%x(element%node(n, 2)) - node%x(element%node(n, 1))

        ! Calculate element's Pressure 1st Derivatives
        do i = 1, 3
            elem_dP(n, 1) = elem_dP(n, 1) + C(2, i)*P(element%node(n, i))
            elem_dP(n, 2) = elem_dP(n, 2) + C(3, i)*P(element%node(n, i))
        end do

        ! Apply element's contribution on its nodes' derivatives' estimation
        do i = 1, 3
            node_dP(element%node(n, i), 1) = node_dP(element%node(n, i), 1)&
                                             + elem_dP(n, 1)
            node_dP(element%node(n, i), 2) = node_dP(element%node(n, i), 2)&
                                             + elem_dP(n, 2)

            ! Add its contribution to the counter
            cnt(element%node(n, i)) = cnt(element%node(n, i)) + 1
        end do

        ! Calculate triangles' sides' lengths
        l12 = dist([node%x(element%node(n, 1)),  &
                    node%y(element%node(n, 1))], &
                   [node%x(element%node(n, 2)),  &
                    node%y(element%node(n, 2))])

        l23 = dist([node%x(element%node(n, 2)),  &
                    node%y(element%node(n, 2))], &
                   [node%x(element%node(n, 3)),  &
                    node%y(element%node(n, 3))])

        l31 = dist([node%x(element%node(n, 3)),  &
                    node%y(element%node(n, 3))], &
                   [node%x(element%node(n, 1)),  &
                    node%y(element%node(n, 1))])

        ! Calculate element's area
        A(n) = (C(2, 1)*C(3, 2) - C(2, 2)*C(3, 1))/2

    end do

    node_dP(:, 1) = node_dP(:, 1)/cnt
    node_dP(:, 2) = node_dP(:, 2)/cnt


    ! Calculate pressure's derivatives' estimation and element error norm
    estm_dP = 0
    err_norm = 0

    do n = 1, size(elem_dP, dim = 1)
        do i = 1, 3
            estm_dP(n, 1) = estm_dP(n, 1) + node_dP(element%node(n, i), 1)/3
            estm_dP(n, 2) = estm_dP(n, 2) + node_dP(element%node(n, i), 2)/3
        end do

        err_norm(n) = sqrt((  (estm_dP(n, 1) - elem_dP(n, 1))**2   &
                            + (estm_dP(n, 2) - elem_dP(n, 2))**2  )*A(n))
    end do


    ! Calculate Mean Error Norm
    mean_err = sum(err_norm)/size(err_norm)

    ! Calculate Error Norm Variance and Standard Deviation
    var_err = sum(err_norm**2)
    var_err = (var_err - size(err_norm)*mean_err**2)/(size(err_norm) - 1)

    stdev_err = sqrt(var_err)


    ! Assign splits
    splits = 0

    do n = 1, size(element%node, dim = 1)
        if (err_norm(n) > mean_err + 1*stdev_err) then
        splits(n) = 1
        end if
    end do


    !! DEBUG
    !print *, "** DEBUG **"
    !print *,
    !print *, "Element dP"
    !print *, "/dx"
    !print "(6F6.2)", elem_dP(:, 1)
    !print *, "/dy"
    !print "(6F6.2)", elem_dP(:, 2)
    !print *,
    !print *, "Node dP"
    !print *, "/dx"
    !print "(4F6.2)", node_dP(:, 1)
    !print *, "/dy"
    !print "(4F6.2)", node_dP(:, 2)
    !print *,
    !print *, "Element Estimated dP"
    !print *, "/dx"
    !print "(6F6.2)", estm_dP(:, 1)
    !print *, "/dy"
    !print "(6F6.2)", estm_dP(:, 2)
    !print *,
    !print *, "Error Norm"
    !print "(6F6.2)", err_norm
    !print *,
    print *, "Mean:", mean_err
    !print *, "Variance:", var_err
    print *, "Standard Deviation:", stdev_err
    !print *,
    !print *, "Splits"
    !print "(I1)", splits
    print *, "required splits:", count(splits /= 0)
    print *, "number of elements:", size(element%He)
    print *,

end subroutine evaluate
